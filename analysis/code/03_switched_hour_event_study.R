# =============================================================================
# 03_switched_hour_event_study.R
#
# Event study for the light-switched evening hour (bin 0 relative to standard
# sunset) and the hour before it (bin -1). Same Poisson triple difference as
# 02_sunset_design.R, with treated x window interacted with each season
# (reference 2018/19, the last DST season).
#
# Also a placebo in time: the pooled estimate is compared with the estimates
# obtained by pretending abolition happened in each pre-period season, using
# pre-period data only.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
})

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))

es <- rbindlist(lapply(TRAFFIC, function(o) rbindlist(lapply(c(0L, -1L), function(b) {
  p <- make_panel(ev, days, o, b)
  m <- fepois(as.formula(paste("y ~ i(sy, tw, ref = LAST_PRE)", FE)), data = p, cluster = ~uf)
  ct <- as.data.table(coeftable(m), keep.rownames = "term")
  rbind(ct[, .(outcome = o, bin = b, sy = as.integer(sub("sy::(\\d+):tw", "\\1", term)),
               coef = Estimate, se = `Std. Error`)],
        data.table(outcome = o, bin = b, sy = LAST_PRE, coef = 0, se = 0))
}))))

fake_years <- (min(SEASONS) + 2L):(LAST_PRE - 1L)
plac <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L)
  real <- coef(fepois(as.formula(paste("y ~ twp", FE)), data = p))[["twp"]]
  pre  <- p[post == 0]
  fake <- sapply(fake_years, function(s) {
    pre[, fp := tw * (sy >= s)]
    coef(fepois(as.formula(paste("y ~ fp", FE)), data = pre))[["fp"]]
  })
  data.table(outcome = o, real = real, fake_min = min(fake), fake_max = max(fake),
             n_fake = length(fake), n_fake_larger = sum(abs(fake) >= abs(real)))
}))

# Figure: drawn by 20_figures.R from the cache saved below.

saveRDS(list(event_study = es, placebo = plac), file.path(path_audit, "switched_hour_event_study.rds"))
options(width = 150)
w <- dcast(es, sy ~ outcome + bin, value.var = "coef")
print(w[, lapply(.SD, function(x) round(100 * x, 1)), by = sy])
print(plac[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
