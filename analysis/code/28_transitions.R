# =============================================================================
# 28_transitions.R
#
# The same change of light before travel adjusts. When DST ended in February,
# the evening hour 0 went from daylight to dark overnight, with travel still at
# the same clock hours; when it started in October, the reverse. Comparing
# hour 0 in the three weeks after each change with the three weeks before
# measures the effect of the light before anyone could adapt; abolition
# measures it after five summers of adapting.
#
# For each transition, days within 21 days of it (21 before, 21 from the day of
# the change), seasons 2008/09-2018/19, dates from build/manual/hv_temporadas.csv.
# The seasons after abolition supply the same calendar days without a change
# of clock, at the dates the 2008 rule would have set (third Sunday of
# October; third Sunday of February, a week later on Carnival Sunday), so the
# seasonal change in mid-October and mid-February is netted out:
#
#   y[u,d] ~ treated x after x DST era | uf^sy + uf^after + date
#
# Hour 0 is the clock hour after standard-time sunset, as in 01. A change of
# clock also moves an hour of sleep (lost in October, gained in February),
# which acts on every hour of the day; the second version compares hour 0
# with hours of the same state and day whose light did not change (the
# reference hours of 09), which nets it out:
#
#   y[u,d,b] ~ 1[b = 0] x treated x after x DST era
#              | uf^date + uf^bin^sy + uf^bin^after + bin^date
#
# Both transitions enter one stacked model (fixed effects interacted with the
# transition) so that the average of the two, with the October sign reversed
# (both read as the effect of a darker evening), has a clustered standard
# error.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

ev  <- as.data.table(read_parquet(EVENTS_FILE))
K   <- 21L
REF <- c(-5:-3, 2:4)                     # reference hours of 09_within_day.R

nth_sunday <- function(y, mo, n) {
  d <- as.IDate(sprintf("%d-%02d-01", y, mo))
  d + (7L - wday(d) + 1L) %% 7L + 7L * (n - 1L)
}
cal <- fread(file.path(path_manual, "hv_temporadas.csv"))[
  , .(sy = as.integer(substr(temporada, 1, 4)), start = as.IDate(inicio), end = as.IDate(fim))][
  sy >= 2008L & sy <= LAST_PRE]
post_s <- season_range()[season_range() > LAST_PRE]
pseudo <- rbindlist(lapply(post_s, function(s) {
  e <- nth_sunday(s + 1L, 2L, 3L)
  if (e == easter_date(s + 1L) - 49L) e <- e + 7L
  data.table(sy = s, start = nth_sunday(s, 10L, 3L), end = e)
}))
cal <- rbind(cal, pseudo)[, era := as.integer(sy <= LAST_PRE)]
# The rule reproduces the decree dates of 2008/09-2017/18.
chk <- cal[sy <= 2017L, .(sy, start, end)]
stopifnot(all(chk$start == nth_sunday(chk$sy, 10L, 3L)))

frame <- function(tr) rbindlist(lapply(seq_len(nrow(cal)), function(i) {
  t0 <- cal[[tr]][i]
  CJ(uf = c(TREATED, CONTROL), date = seq(t0 - K, t0 + K - 1L, by = 1L))[
    , `:=`(sy = cal$sy[i], era = cal$era[i], after = as.integer(date >= t0))]
}))[, `:=`(treated = as.integer(uf %in% TREATED), transition = tr)][
  , x := treated * after * era]

res <- rbindlist(lapply(TRAFFIC, function(o) {
  d <- rbind(frame("end"), frame("start"))
  d[, `:=`(x_end = x * (transition == "end"), x_start = x * (transition == "start"))]
  # Hour 0 alone.
  y <- ev[outcome == o & bin_set == 0L, .(y = sum(w)), by = .(uf, date)]
  p <- y[d, on = .(uf, date)][is.na(y), y := 0]
  m <- fepois(y ~ x_end + x_start | transition^uf^sy + transition^uf^after + transition^date,
              data = p, cluster = ~uf, notes = FALSE)
  # Hour 0 against hours of the same state and day.
  bins <- c(REF, 0L)
  y4 <- ev[outcome == o & bin_set %in% bins, .(y = sum(w)), by = .(uf, date, bin = bin_set)]
  g4 <- d[, .(bin = bins), by = .(uf, date, sy, era, after, treated, transition, x_end, x_start)]
  p4 <- y4[g4, on = .(uf, date, bin)][is.na(y), y := 0]
  p4[, `:=`(x_end = x_end * (bin == 0L), x_start = x_start * (bin == 0L))]
  m4 <- fepois(y ~ x_end + x_start | transition^uf^date + transition^uf^bin^sy +
                 transition^uf^bin^after + transition^bin^date,
               data = p4, cluster = ~uf, notes = FALSE)
  rbindlist(lapply(list(hour0 = m, within_day = m4), function(mm) {
    b <- coef(mm)[c("x_end", "x_start")]; V <- vcov(mm)[names(b), names(b)]
    a <- c(0.5, -0.5)
    data.table(end_lp = 100 * b[[1]], end_se = 100 * sqrt(V[1, 1]),
               start_lp = 100 * b[[2]], start_se = 100 * sqrt(V[2, 2]),
               avg_dark_lp = 100 * sum(a * b), avg_dark_se = 100 * sqrt(drop(t(a) %*% V %*% a)))
  }), idcol = "design")[, outcome := o][]
}))
res[, n_days_each_side := K]

# The regime, for the comparison: hour 0 in the triple difference (01) and
# within the day (09).
reg <- readRDS(file.path(path_audit, "sunset_design.rds"))$results[
  outcome %in% TRAFFIC & bin == 0L & grepl("^evening", side), .(outcome, design = "hour0",
                                                                 regime_lp = 100 * coef, regime_se = 100 * se)]
reg <- rbind(reg, readRDS(file.path(path_audit, "within_day.rds"))$pooled[
  side == "set" & reference == "all" & bin == 0L, .(outcome, design = "within_day",
                                                    regime_lp = 100 * coef, regime_se = 100 * se)])
res <- reg[res, on = .(outcome, design)]

saveRDS(list(results = res, calendar = cal, k = K), file.path(path_audit, "transitions.rds"))
options(width = 200)
print(cal)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
