# =============================================================================
# 22_heaping.R
#
# Robustness of the evening light-switched hour to heaping of recorded clock
# times. Code audit 12/10/2026: 34.5% of on-road SIM death times are on the
# full hour and 23% on the half hour (PRF: 21% and 19%); 90-95% are multiples
# of 5 minutes. The hour bins are fixed relative to the computed standard-time
# sunset, so a heap at 19:00 falls inside or outside bin 0 depending on the
# date and place, and a solar formula that moves sunset by at most 1.6 minutes
# moved the SIM estimate from 29.2 to 29.8 log points.
#
# Same Poisson triple difference as 02 for clock [sunset_std + s, + 60 min):
#   shift  s = -15, -10, -5, 0, +5, +10, +15 minutes
#   drop   s = 0, events recorded at :00 or :30 removed (in every cell, so the
#          comparison stays like for like)
#   solar  s = 0, sunset from the full NOAA solar calculator (Meeus) instead of
#          the NOAA general equations of 00_utils.R; at most 1.6 minutes apart
#          over all event dates (sunset_gap in the cache)
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
geo  <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output",
                                             "muni_geo.parquet")))
ev <- as.data.table(read_parquet(EVENTS_FILE))[outcome %in% TRAFFIC]
ev <- geo[, .(code6, lat, lon, std_offset_h)][ev, on = "code6"]
stopifnot(!anyNA(ev$lat))
ev[, rel := cmin - sun_times(date, lat, lon, std_offset_h)$sunset]
# The minutes recomputed here must give back the bins of the event file.
stopifnot(all(floor(ev$rel / 60) == ev$bin_set))
ev[, heap := cmin %% 30L == 0L]

# Full NOAA solar calculator (Meeus, Astronomical Algorithms), sunset in
# minutes after local standard midnight.
sunset_meeus <- function(date, lat, lon, off) {
  rad <- pi / 180
  jd <- as.numeric(as.Date(date)) + 2440587.5 + 0.5 - off / 24
  T  <- (jd - 2451545) / 36525
  L0 <- (280.46646 + T * (36000.76983 + T * 0.0003032)) %% 360
  M  <- 357.52911 + T * (35999.05029 - 0.0001537 * T)
  e  <- 0.016708634 - T * (0.000042037 + 0.0000001267 * T)
  C  <- sin(M * rad) * (1.914602 - T * (0.004817 + 0.000014 * T)) +
    sin(2 * M * rad) * (0.019993 - 0.000101 * T) + sin(3 * M * rad) * 0.000289
  om  <- 125.04 - 1934.136 * T
  lam <- L0 + C - 0.00569 - 0.00478 * sin(om * rad)
  eps <- 23 + (26 + (21.448 - T * (46.815 + T * (0.00059 - T * 0.001813))) / 60) / 60 +
    0.00256 * cos(om * rad)
  dec <- asin(sin(eps * rad) * sin(lam * rad))
  y   <- tan(eps * rad / 2)^2
  eot <- 4 / rad * (y * sin(2 * L0 * rad) - 2 * e * sin(M * rad) +
                      4 * e * y * sin(M * rad) * cos(2 * L0 * rad) -
                      0.5 * y^2 * sin(4 * L0 * rad) - 1.25 * e^2 * sin(2 * M * rad))
  ha <- acos(cos(90.833 * rad) / (cos(lat * rad) * cos(dec)) - tan(lat * rad) * tan(dec)) / rad
  720 - 4 * lon - eot + 60 * off + 4 * ha
}
ev[, rel_meeus := cmin - sunset_meeus(date, lat, lon, std_offset_h)]
sunset_gap <- ev[, .(max_abs_min = max(abs(rel - rel_meeus)))]

fit <- function(sel) {
  y <- ev[sel, .(y = sum(w)), by = .(uf, date)]
  p <- y[days, on = .(uf, date)][is.na(y), y := 0]
  m <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf, notes = FALSE)
  list(lp = 100 * coef(m)[["twp"]], se = 100 * se(m)[["twp"]],
       pre_per_season = p[tw == 1 & post == 0, sum(y)] / sum(SEASONS <= LAST_PRE))
}

SHIFTS <- c(-15L, -10L, -5L, 0L, 5L, 10L, 15L)
res <- rbindlist(lapply(TRAFFIC, function(o) rbind(
  rbindlist(lapply(SHIFTS, function(s)
    data.table(outcome = o, variant = "shift", shift_min = s,
               as.data.table(fit(ev$outcome == o & ev$rel >= s & ev$rel < s + 60)))))
  ,
  data.table(outcome = o, variant = "drop :00 and :30", shift_min = 0L,
             as.data.table(fit(ev$outcome == o & ev$rel >= 0 & ev$rel < 60 & !ev$heap))),
  data.table(outcome = o, variant = "Meeus solar algorithm", shift_min = 0L,
             as.data.table(fit(ev$outcome == o & ev$rel_meeus >= 0 & ev$rel_meeus < 60)))
)))
heap_share <- ev[, .(full_hour_pct = 100 * mean(cmin %% 60L == 0L),
                     half_hour_pct = 100 * mean(cmin %% 60L == 30L),
                     mult5_pct = 100 * mean(cmin %% 5L == 0L)), by = outcome]

saveRDS(list(results = res, heap_share = heap_share, sunset_gap = sunset_gap), file.path(path_audit, "heaping.rds"))
options(width = 160)
print(heap_share)
print(sunset_gap)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
