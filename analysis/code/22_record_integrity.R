# =============================================================================
# 22_record_integrity.R
#
# Did the way deaths are recorded change differentially with abolition? Two
# shares, from all SIM land-transport deaths (V01-V89, any place):
#   on_road   share that occurred on the public road (LOCOCOR = 4); moves if
#             pre-hospital care (SAMU) reaches victims sooner in one region;
#   no_time   among on-road deaths, share without a valid clock time; those
#             deaths never enter the hourly design.
#   ped_no_time, ped_time  among on-road deaths without and with a clock time,
#             share of pedestrians (V01-V09): do the deaths the hourly design
#             misses change composition with abolition, relative to those it sees?
# Cells are UF x season x window (summer window / off-season, as in make_days).
# Test: linear triple difference on the share, cells weighted by deaths,
#   share ~ treated x window x post | uf^window + uf^sy + window^sy,
# standard errors clustered by state.
#
# Also: how close is the clock time on the death certificate to the time of
# the crash? A federal highway crash with one death and the only on-road
# transport death certificate with a clock time in the same municipality and
# on the same date are, most of the time, the same event. For those pairs,
# lag = certificate time minus crash time (minutes). Pairs formed with the
# certificates of the same municipality seven days later, which cannot be the
# same event, give the distribution expected by chance.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
sim <- rbindlist(lapply((min(SEASONS)):(max(SEASONS) + 1L), function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "LOCOCOR",
                                            "CAUSABAS", "preliminary")))))
stopifnot(!any(sim$preliminary))
sim <- sim[CAUSABAS >= "V01" & CAUSABAS < "V90"]
sim[, `:=`(uf = code_to_uf[substr(CODMUNOCOR, 1, 2)], date = as.IDate(DTOBITO, format = "%d%m%Y"))]
sim <- unique(days[, .(uf, date, sy, window, treated, post)])[sim, on = .(uf, date), nomatch = 0]
sim[, `:=`(on_road = as.integer(LOCOCOR %in% "4"), no_time = as.integer(is.na(clock_min(HORAOBITO))))]

cells <- rbind(
  sim[, .(measure = "on_road", share = mean(on_road), n = .N), by = .(uf, sy, window, treated, post)],
  sim[on_road == 1L, .(measure = "no_time", share = mean(no_time), n = .N), by = .(uf, sy, window, treated, post)],
  sim[on_road == 1L & no_time == 1L, .(measure = "ped_no_time", share = mean(CAUSABAS < "V10"), n = .N), by = .(uf, sy, window, treated, post)],
  sim[on_road == 1L & no_time == 0L, .(measure = "ped_time", share = mean(CAUSABAS < "V10"), n = .N), by = .(uf, sy, window, treated, post)])
cells[, `:=`(win = as.integer(window == "win"))][, twp := treated * win * post]

test <- rbindlist(lapply(c("on_road", "no_time", "ped_no_time", "ped_time"), function(ms) {
  m <- feols(share ~ twp | uf^window + uf^sy + window^sy, data = cells[measure == ms],
             weights = ~n, cluster = ~uf)
  data.table(measure = ms, pp = 100 * coef(m)[["twp"]], se_pp = 100 * se(m)[["twp"]],
             p = pvalue(m)[["twp"]], mean_pct = 100 * cells[measure == ms, weighted.mean(share, n)])
}))
series <- cells[measure %in% c("on_road", "no_time"), .(share = 100 * sum(share * n) / sum(n), n = sum(n)),
                by = .(measure, group = fifelse(treated == 1L, "treated", "control"), window, sy)]

# Clock check, as for the traffic counts (15): if certificates carried
# STANDARD time, the treated states' summer profile of on-road deaths by clock
# hour would sit one hour earlier under DST. Treated summer net of the treated
# off-season and of the control's same contrast, pre vs post; lag k moves the
# pre profile k hours later.
prof <- sim[on_road == 1L & !is.na(clock_min(HORAOBITO)),
            .N, by = .(treated, window, post, hour = clock_min(HORAOBITO) %/% 60L)]
prof[, share := N / sum(N), by = .(treated, window, post)]
w <- dcast(prof, hour ~ treated + window + post, value.var = "share", fill = 0)
stopifnot(nrow(w) == 24L)
net <- function(t, p) w[[sprintf("%d_win_%d", t, p)]] - w[[sprintf("%d_off_%d", t, p)]]
pre  <- net(1, 0) - net(0, 0)
post <- net(1, 1) - net(0, 1)
shift <- function(x, k) x[((seq_along(x) - 1L - k) %% 24L) + 1L]
clock <- data.table(lag = -1:1, sq_dist = sapply(-1:1, function(k) 1e4 * sum((shift(pre, k) - post)^2)))

# ── Certificate time against crash time ─────────────────────────────────────
ev <- as.data.table(read_parquet(EVENTS_FILE))[outcome %in% c("PRF deaths", "SIM transport deaths, on road")]
one <- function(o, cond) ev[outcome == o & cond, .(n = .N, cmin = cmin[1], w = w[1]), by = .(code6, date)][n == 1L]
crash <- one("PRF deaths", TRUE)[w == 1]
death <- one("SIM transport deaths, on road", TRUE)
pair_lag <- function(shift_days) {
  d <- copy(death)[, date := date - shift_days]
  x <- crash[d, on = .(code6, date), nomatch = 0]
  lag <- x$i.cmin - x$cmin
  lag[lag > 720] <- lag[lag > 720] - 1440
  lag[lag <= -720] <- lag[lag <= -720] + 1440
  lag
}
lag_same <- pair_lag(0L); lag_chance <- pair_lag(7L)
summ <- function(l) data.table(pairs = length(l), median_min = median(l),
                               within_0_60_pct = 100 * mean(l >= 0 & l < 60),
                               within_30_pct = 100 * mean(abs(l) <= 30),
                               negative_pct = 100 * mean(l < 0))
link <- rbind(cbind(pairing = "same date", summ(lag_same)),
              cbind(pairing = "seven days later (chance)", summ(lag_chance)))

saveRDS(list(test = test, series = series, clock = clock, link = link),
        file.path(path_audit, "record_integrity.rds"))
print(link)
options(width = 160)
print(clock)
print(test[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
print(dcast(series[window == "win"], sy ~ measure + group, value.var = "share")[, lapply(.SD, round, 1)])
