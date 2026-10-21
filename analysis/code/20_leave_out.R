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
#   (e) without Carnival and the year-end holidays (holiday_days, 00_utils.R),
#       and without the 279 municipalities that face the sea (IBGE list,
#       build/14), where the summer trips to the beaches go;
#   (f) school weeks against school holidays inside the summer window: one
#       model with separate effects for the parts of school_part() (00_utils.R:
#       classes 15 November to 7 December, holidays 24 December to 15 January,
#       the rest and 2020/21 apart); the state x window effect is split into
#       the same parts. The three weeks after each clock change before 2019
#       (26_transitions.R) fall in term time, so this asks whether the
#       abolition effect differs between term time and the holidays. Para, a
#       control state, runs its school year from March to January (2019:
#       11 March 2019 to 30 January 2020), so the split is repeated without it.
#       The holidays are split again into the year-end days (24 December to
#       1 January) and the January weeks, and estimated without the coastal
#       municipalities (beach trips); a placebo repeats the split on the
#       seasons before abolition, as if it had come in 2014/15;
#   (g) the control states counted at the treated states' clock time. In the
#       treated states' summer, hour 0 falls 50 to 90 minutes later on the
#       clock than in the other three cells (control summer, both
#       off-seasons). A change after 2019 in the risk at that clock time,
#       anywhere in the country, would load on the estimate. Here the control
#       states' events are counted in the clock window [s_d, s_d + 60), where
#       s_d is the treated states' standard-time sunset on date d (average
#       over treated municipal seats, weighted by on-road deaths before
#       abolition), so both groups are compared at the same clock time on
#       every date.
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
COAST <- read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output", "muni_coastal.parquet"))$code6

# s_d: treated states' clock time of hour 0 on each date (f).
wt <- seat_weights(ev[uf %in% TREATED], by = "code6")
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

school_est <- function(o, p, suffix = "") {
  p[, part := school_part(date, window, sy)]
  p[, `:=`(t_school = twp * (part == "school"), t_hol = twp * (part == "holiday"),
           t_oth = twp * (part == "other"))]
  m <- fepois(y ~ t_school + t_hol + t_oth | uf^part + uf^sy + date,
              data = p, cluster = ~uf, notes = FALSE)
  b <- coef(m); V <- vcov(m)
  data.table(outcome = o, kind = "school",
             dropped = paste0(c("school weeks", "school holidays", "school weeks minus holidays"), suffix),
             lp = 100 * c(b[["t_school"]], b[["t_hol"]], b[["t_school"]] - b[["t_hol"]]),
             se = 100 * sqrt(c(V["t_school", "t_school"], V["t_hol", "t_hol"],
                               V["t_school", "t_school"] + V["t_hol", "t_hol"] -
                                 2 * V["t_school", "t_hol"])))
}

# The holidays split into the year-end days (24 December to 1 January:
# Christmas, New Year) and the January weeks (2 to 15 January), in one model.
yearend_est <- function(o, p) {
  p[, part := school_part(date, window, sy)]
  p[part == "holiday", part := fifelse(month(date) == 12L | (month(date) == 1L & mday(date) == 1L),
                                       "yearend", "january")]
  p[, `:=`(t_school = twp * (part == "school"), t_ye = twp * (part == "yearend"),
           t_jan = twp * (part == "january"), t_oth = twp * (part == "other"))]
  m <- fepois(y ~ t_school + t_ye + t_jan + t_oth | uf^part + uf^sy + date,
              data = p, cluster = ~uf, notes = FALSE)
  data.table(outcome = o, kind = "school",
             dropped = c("school holidays, 24 December to 1 January", "school holidays, 2 to 15 January"),
             lp = 100 * coef(m)[c("t_ye", "t_jan")], se = 100 * se(m)[c("t_ye", "t_jan")])
}
# Placebo: the seasons before abolition only, 2014/15-2018/19 against
# 2008/09-2013/14, as if abolition had come in 2014.
placebo_days <- function(p) {
  q <- p[sy <= LAST_PRE]
  q[, twp := tw * as.integer(sy >= 2014L)]
  q
}

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
    data.table(outcome = o, kind = "places", dropped = "coastal municipalities",
               as.data.table(est(make_panel(ev[!code6 %in% COAST], days, o, 0L, "set")))),
    school_est(o, copy(p)),
    school_est(o, copy(p[uf != "PA"]), ", without Para"),
    yearend_est(o, copy(p)),
    school_est(o, make_panel(ev[!code6 %in% COAST], days, o, 0L, "set"), ", without the coast"),
    school_est(o, placebo_days(copy(p)), ", placebo 2014"),
    data.table(outcome = o, kind = "clock", dropped = "control states at the treated clock time",
               as.data.table(est(clock_panel(o, p)))))
}))

saveRDS(res, file.path(path_audit, "leave_out.rds"))
options(width = 160)
print(sbar[, .(sbar_min = range(sbar))])
print(res[kind %in% c("baseline", "control", "seasons", "days", "places", "school", "clock"), lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
print(res[kind %in% c("state", "season"), .(min_lp = round(min(lp), 1), which_min = dropped[which.min(lp)],
                                            max_lp = round(max(lp), 1), which_max = dropped[which.max(lp)]),
          by = .(outcome, kind)])
