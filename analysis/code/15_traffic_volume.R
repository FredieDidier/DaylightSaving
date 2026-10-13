# =============================================================================
# 15_traffic_volume.R
#
# Did traffic move in time when the clock stopped changing? PNCT continuous
# count stations on federal highways (build/06-07), hourly volume, 2014-2019
# and 2021-2025.
#
#   (a) Clock check. If the stations log LEGAL time, the treated states' daily
#       profile in the summer window keeps its clock-hour shape across regimes
#       (people follow the clock). If they log STANDARD time, every DST-era
#       summer profile sits one hour earlier. Compare the treated-summer
#       profile pre vs post (each net of the control's) at lags -1, 0, +1.
#   (b) Triple difference in volume, hour by hour relative to STANDARD-time
#       sunset and sunrise at the station (same bins as 01/11; an hourly
#       count goes to the bin that contains the midpoint of its clock hour):
#         y[s,d] ~ treated x window x post | station + uf^window + uf^sy + date
#       Poisson on vehicles, EP clustered by UF. No station is counted both
#       before and after abolition (the 2020 contract replaced every device),
#       so seasonality sits at the UF level; robustness on the 30 relocated
#       station pairs (a post-only station within 2 km of a pre-only one on the same
#       BR), with pair^window + pair^sy fixed effects.
#   (c) Within the day: stacked bins with station x date fixed effects and the
#       rest of the day as reference, so a coefficient is the change in that
#       hour's traffic relative to the rest of the same station-day.
#   (d) Risk per vehicle: crash effect (11_reallocation.R, PRF) minus volume
#       effect, hour by hour, in log points.
#
# Groups as everywhere: treated RS SC PR SP RJ ES MG GO MT MS DF; control the
# North and Northeast without BA, TO, AC, AM. Only complete, counted
# station-days (24 clock hours; no modelled days; nothing from Jun 2019 to
# Dec 2020). Summer windows: 2014/15-2018/19 pre, 2021/22-2024/25 post.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(ggplot2)
})

pn <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "pnct", "output",
                                           "pnct_hourly.parquet")))
pn <- pn[uf %in% c(TREATED, CONTROL)]
# Counted traffic only: drop station-days flagged as modelled (07_clean_pnct.R)
# and the whole gap between the end of the counting contract (June 2019) and
# the new contract (2021): DNIT published modelled values for 2019-H2 and
# nothing for 2020.
pn <- pn[!imputed & !(date >= as.IDate("2019-06-01") & date < as.IDate("2021-01-01"))]

# Hourly vehicles per station-date-hour (both directions); complete days only.
hv <- pn[, .(v = sum(total), v_light = sum(light), v_heavy = sum(heavy), n_dir = uniqueN(dir)),
         by = .(station, uf, lat, lon, date, hour)]
full <- hv[, .(n_h = uniqueN(hour), n_dir = min(n_dir), v_day = sum(v)), by = .(station, date)]
full <- full[n_h == 24L & v_day > 0]
hv <- hv[full[, .(station, date)], on = .(station, date), nomatch = 0]

# Season frame (as make_days, at the station level).
hv[, sy := year(date) - (month(date) < 7L)]
md <- hv[, month(date) * 100L + mday(date)]
hv[, window := fcase(md >= 1115L | md <= 214L, "win", md >= 401L & md <= 831L, "off")]
hv <- hv[!is.na(window)]
hv[, `:=`(treated = as.integer(uf %in% TREATED), win = as.integer(window == "win"),
          post = as.integer(sy > LAST_PRE))]
hv[, `:=`(tw = treated * win, twp = treated * win * post)]

# ── (a) Clock check ─────────────────────────────────────────────────────────
prof <- hv[, .(v = sum(v)), by = .(treated, window, post, hour)]
prof[, share := v / sum(v), by = .(treated, window, post)]
w <- dcast(prof, hour ~ treated + window + post, value.var = "share")
# Treated summer profile, net of the treated off-season and of the control's
# same contrast, pre vs post. Lag k shifts the pre profile by k hours.
net <- function(t, p) w[[sprintf("%d_win_%d", t, p)]] - w[[sprintf("%d_off_%d", t, p)]]
pre  <- net(1, 0) - net(0, 0)
post <- net(1, 1) - net(0, 1)
shift <- function(x, k) x[((seq_along(x) - 1L - k) %% 24L) + 1L]
clock <- data.table(lag = -1:1, sq_dist = sapply(-1:1, function(k) 1e4 * sum((shift(pre, k) - post)^2)))
# Raw treated summer profiles, for eyeballing the morning peak.
peak <- prof[treated == 1 & window == "win" & hour %in% 4:9,
             .(hour, post, share = round(100 * share, 2))]

# ── (b) Triple difference by sun bin ────────────────────────────────────────
off_h <- function(uf) fcase(uf == "AC", -5, uf %in% c("MS", "MT", "RO", "RR", "AM"), -4, default = -3)
st <- hv[, sun_times(date, lat, lon, off_h(uf))]
mid <- 60L * hv$hour + 30L
hv[, `:=`(bin_set = floor((mid - st$sunset) / 60), bin_rise = floor((mid - st$sunrise) / 60))]
HOURS <- rbind(data.table(side = "set", bin = -3:2), data.table(side = "rise", bin = -2:2))
HOURS[, key := sprintf("%s%+d", fifelse(side == "set", "eve", "morn"), bin)]

sd <- unique(hv[, .(station, uf, date, window, sy, treated, win, post, tw, twp)])
bin_panel <- function(side, b, var = "v") {
  col <- if (side == "set") "bin_set" else "bin_rise"
  y <- hv[get(col) == b, .(y = sum(get(var))), by = .(station, date)]
  p <- y[sd, on = .(station, date)]
  p[is.na(y), y := 0]
  p[]
}
# No station is counted both before and after abolition: the 2020 contract
# replaced every device and almost always moved the km (counts of pre-only,
# post-only and both are printed under Coverage). A station x window effect would absorb
# treated x window x post, so seasonality is modelled at the UF level and the
# station effect only absorbs the level of its road.
FEV <- "| station + uf^window + uf^sy + date"

# Relocated stations: each post-only station within 2 km of a pre-only one on
# the same BR forms a pair; the pair is followed across regimes.
loc <- unique(hv[, .(station, uf, lat, lon, post)])[
  , .(pre = any(post == 0L), postp = any(post == 1L), lat = lat[1], lon = lon[1]), by = .(station, uf)]
loc <- unique(pn[, .(station, br, km)])[loc, on = "station"]
pairs <- loc[postp & !pre][loc[pre & !postp], on = .(uf, br), allow.cartesian = TRUE, nomatch = 0][
  abs(km - i.km) <= 2]
pairs <- pairs[order(abs(km - i.km))][, .SD[1], by = station]
pairs <- pairs[, .SD[1], by = i.station]
pairs[, pair := paste(station, i.station, sep = "~")]
pair_map <- rbind(pairs[, .(station, pair)], pairs[, .(station = i.station, pair)])
ddd <- rbindlist(lapply(seq_len(nrow(HOURS)), function(i) rbindlist(lapply(c("v", "v_light", "v_heavy"), function(var) {
  p <- bin_panel(HOURS$side[i], HOURS$bin[i], var)
  m <- fepois(as.formula(paste("y ~ twp", FEV)), data = p, cluster = ~uf, notes = FALSE)
  data.table(bin_key = HOURS$key[i], vehicles = var, coef_lp = 100 * coef(m)[["twp"]],
             se_lp = 100 * se(m)[["twp"]], n_station_days = nobs(m))
}))))
ddd[, p := 2 * pnorm(-abs(coef_lp / se_lp))]
paired <- rbindlist(lapply(seq_len(nrow(HOURS)), function(i) {
  p <- pair_map[bin_panel(HOURS$side[i], HOURS$bin[i]), on = "station", nomatch = 0]
  m <- fepois(y ~ twp | pair^window + pair^sy + date, data = p, cluster = ~uf, notes = FALSE)
  data.table(bin_key = HOURS$key[i], coef_lp = 100 * coef(m)[["twp"]], se_lp = 100 * se(m)[["twp"]],
             n_pairs = uniqueN(p$pair))
}))
day <- {
  p <- sd[full, on = .(station, date), nomatch = 0][, y := v_day]
  m <- fepois(as.formula(paste("y ~ twp", FEV)), data = p, cluster = ~uf, notes = FALSE)
  data.table(bin_key = "whole day", vehicles = "v", coef_lp = 100 * coef(m)[["twp"]], se_lp = 100 * se(m)[["twp"]])
}

# ── (c) Within the day ──────────────────────────────────────────────────────
# The 11 sun hours plus the reference "rest" (the other 13 clock hours of the
# station-day). Without a reference the model is not identified: under the
# station x date effect, adding a constant to every hour's coefficient changes
# nothing, and the standard errors explode. Each coefficient reads as the
# change in that hour's traffic relative to the rest of the same station-day.
stack <- rbindlist(lapply(seq_len(nrow(HOURS)), function(i)
  bin_panel(HOURS$side[i], HOURS$bin[i])[, key := HOURS$key[i]]))
rest <- stack[, .(y = sum(y)), by = .(station, date)][full[, .(station, date, v_day)], on = .(station, date), nomatch = 0]
rest <- sd[rest[, .(station, date, y = v_day - y)], on = .(station, date)][, key := "rest"]
stopifnot(rest[, all(y >= 0)])
stack <- rbind(stack, rest, use.names = TRUE)
# The panel is saved for 16_inference_volume.R (the build above takes minutes).
write_parquet(stack, file.path(DROPBOX_ROOT, "build", "pnct", "output", "pnct_station_day_bins.parquet"))
# Station x hour absorbs each road's own daily profile; the window and season
# contrasts of the profile sit at the UF level (see FEV).
wd <- fepois(y ~ i(key, twp, ref = "rest") | station^date + station^key + uf^key^window + uf^key^sy + key^date,
             data = stack, cluster = ~uf, notes = FALSE)
within <- data.table(bin_key = sub("key::(.*):twp", "\\1", names(coef(wd))),
                     coef_lp = 100 * coef(wd), se_lp = 100 * se(wd))
within[, p := 2 * pnorm(-abs(coef_lp / se_lp))]

# ── (d) Risk per vehicle (PRF crashes minus volume, same hour) ──────────────
rl <- readRDS(file.path(path_audit, "reallocation.rds"))$hours
risk <- merge(rl[outcome != "SIM transport deaths, on road", .(outcome, bin_key = hour, crash_lp = coef_lp, crash_se = se_lp)],
              ddd[vehicles == "v", .(bin_key, vol_lp = coef_lp, vol_se = se_lp)], by = "bin_key")
risk[, `:=`(per_vehicle_lp = crash_lp - vol_lp, per_vehicle_se = sqrt(crash_se^2 + vol_se^2))]

# ── Coverage ────────────────────────────────────────────────────────────────
cover <- sd[, .(stations = uniqueN(station), station_days = .N),
            keyby = .(group = fifelse(treated == 1, "treated", "control"), sy, window)]

saveRDS(list(clock = clock, peak = peak, ddd = ddd, day = day, paired = paired, within = within,
             risk = risk, cover = cover, pairs = pairs), file.path(path_audit, "traffic_volume.rds"))
options(width = 180)
cat("(a) Clock check: distance between treated-summer net profiles, pre shifted by lag vs post\n")
print(clock); print(dcast(peak, hour ~ post, value.var = "share"))
cat("\nCoverage:\n"); print(dcast(cover, sy ~ group + window, value.var = "stations"))
print(loc[, .(pre_only = sum(pre & !postp), post_only = sum(postp & !pre), both = sum(pre & postp))])
cat("\n(b) Triple difference in volume (log points):\n")
print(dcast(ddd, bin_key ~ vehicles, value.var = "coef_lp")[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
print(ddd[vehicles == "v", .(bin_key, coef_lp = round(coef_lp, 1), se_lp = round(se_lp, 1), p = round(p, 3))])
print(day)
cat("\nRelocated-station pairs (all vehicles):\n"); print(paired[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
cat("\n(c) Within the day (share of station-day traffic, log points):\n"); print(within[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
cat("\n(d) Risk per vehicle (PRF):\n"); print(risk[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
