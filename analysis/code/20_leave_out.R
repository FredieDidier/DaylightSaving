# =============================================================================
# 20_leave_out.R
#
# The evening light-switched hour (bin 0) under other samples, same Poisson
# triple difference as 01:
#   (a) leave one state out (23 fits per outcome);
#   (b) leave one season out (16 fits per outcome);
#   (c) other control groups: Northeast only, North only;
#   (d) without the La Nina summers (2020/21-2022/23), and without 2019/20,
#       the first season without DST;
#   (e) without Carnival and the year-end holidays (holiday_days, 00_utils.R);
#   (f) the control states counted at the treated states' clock time. In the
#       treated states' summer, hour 0 falls 50 to 90 minutes later on the
#       clock than in the other three cells (control summer, both
#       off-seasons). A change after 2019 in the risk at that clock time,
#       anywhere in the country, would load on the estimate. Here the control
#       states' events are counted in the clock window [s_d, s_d + 60), where
#       s_d is the treated states' standard-time sunset on date d (average
#       over treated municipal seats, weighted by on-road deaths), so both
#       groups are compared at the same clock time on every date.
# With 11 treated and 12 control states, (a) shows whether one state carries
# the estimate.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))[outcome %in% TRAFFIC]
geo  <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output",
                                             "muni_geo.parquet")))
HOL  <- holiday_days(min(SEASONS):(max(SEASONS) + 1L))

# s_d: treated states' clock time of hour 0 on each date (f).
wt <- ev[outcome == "SIM transport deaths, on road" & uf %in% TREATED, .(n = .N), by = code6]
wt <- geo[, .(code6, lat, lon, std_offset_h)][wt, on = "code6", nomatch = 0]
sbar <- unique(days[, .(date)])[, .(sbar = {
  st <- sun_times(rep(date, nrow(wt)), wt$lat, wt$lon, wt$std_offset_h)$sunset
  sum(wt$n * st) / sum(wt$n)
}), by = date]
evc <- sbar[ev[uf %in% CONTROL], on = "date", nomatch = 0][cmin >= sbar & cmin < sbar + 60]
clock_panel <- function(o, p) {
  yc <- evc[outcome == o, .(yc = sum(w)), by = .(uf, date)]
  q <- yc[copy(p), on = .(uf, date)]
  q[is.na(yc), yc := 0]
  q[uf %in% CONTROL, y := yc]
  q[]
}

NE <- c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE")
NO <- c("RO", "RR", "PA", "AP")
stopifnot(setequal(c(NE, NO), CONTROL))

est <- function(p) {
  m <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf, notes = FALSE)
  list(lp = 100 * coef(m)[["twp"]], se = 100 * se(m)[["twp"]])
}

res <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L, "set")
  rbind(
    data.table(outcome = o, kind = "baseline", dropped = "none", as.data.table(est(p))),
    rbindlist(lapply(c(TREATED, CONTROL), function(u)
      data.table(outcome = o, kind = "state", dropped = u, as.data.table(est(p[uf != u]))))),
    rbindlist(lapply(SEASONS, function(s)
      data.table(outcome = o, kind = "season", dropped = season_lab(s), as.data.table(est(p[sy != s]))))),
    data.table(outcome = o, kind = "control", dropped = "North (control = Northeast only)",
               as.data.table(est(p[!uf %in% NO]))),
    data.table(outcome = o, kind = "control", dropped = "Northeast (control = North only)",
               as.data.table(est(p[!uf %in% NE]))),
    data.table(outcome = o, kind = "seasons", dropped = "La Nina summers 2020/21-2022/23",
               as.data.table(est(p[!sy %in% 2020:2022]))),
    data.table(outcome = o, kind = "seasons", dropped = "2019/20",
               as.data.table(est(p[sy != 2019L]))),
    data.table(outcome = o, kind = "days", dropped = "Carnival and year-end holidays",
               as.data.table(est(p[!date %in% HOL]))),
    data.table(outcome = o, kind = "clock", dropped = "control states at the treated clock time",
               as.data.table(est(clock_panel(o, p)))))
}))

saveRDS(res, file.path(path_audit, "leave_out.rds"))
options(width = 160)
print(sbar[, .(sbar_min = range(sbar))])
print(res[kind %in% c("baseline", "control", "seasons", "days", "clock"), lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
print(res[kind %in% c("state", "season"), .(min_lp = round(min(lp), 1), which_min = dropped[which.min(lp)],
                                            max_lp = round(max(lp), 1), which_max = dropped[which.max(lp)]),
          by = .(outcome, kind)])
