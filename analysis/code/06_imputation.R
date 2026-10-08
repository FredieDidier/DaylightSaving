# =============================================================================
# 06_imputation.R
#
# Imputation estimator (Borusyak, Jaravel & Spiess logic, Poisson version) for
# the light-switched hours, with and without extrapolating a pre-period trend.
#
#   1. Fit the outcome model on UNTREATED observations only: every control
#      UF-day, every off-season day, and treated DST-window days before 2019.
#        A  y ~ 1        | uf^window + uf^sy + week + dow
#        B  y ~ tw:t     | same       (linear treated x window trend, so it is
#                                      estimated from pre-2019 seasons only)
#   2. Predict the counterfactual for treated DST-window days after 2019.
#   3. ATT = sum(observed) / sum(predicted) - 1, overall and by season.
#
# Spec B answers the pre-trend concern without the problem of a trend fitted
# on the whole sample: there, the trend also runs through the post seasons and
# absorbs a growing effect. Here the trend is learned before 2019 and only
# extrapolated.
#
# Time effects: calendar week + day of week instead of date. With date fixed
# effects, post-2019 summer dates are identified by the 12 control states
# alone, and in a single clock hour those are often all zero, which drops the
# date and leaves no counterfactual for the treated observations of that day.
#
# Inference: stratified cluster bootstrap over UFs (11 treated and 12 control
# states drawn with replacement, duplicates relabelled), B = 299. The state
# draws are made up front from the seed, so the result does not depend on how
# many cores fit them (DS_CORES, default 5).
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

B <- as.integer(Sys.getenv("DS_BOOT", unset = "299"))
CORES <- as.integer(Sys.getenv("DS_CORES", unset = "5"))
set.seed(20191103)                       # the Sunday DST would have started

SEASONS <- season_range()
days <- make_days(SEASONS)
days[, `:=`(week = (as.integer(date) - as.integer(min(date))) %/% 7L, dow = wday(date))]
ev <- as.data.table(read_parquet(EVENTS_FILE))

FE_I <- "| uf^window + uf^sy + week + dow"

# tol: convergence tolerance of the fixed-effect demeaning. The bootstrap uses
# 1e-4 instead of the default 1e-6: on PRF deaths it cuts a fit from ~26 s to
# ~3 s and moves the ATT in the fifth decimal (0.25647 vs 0.25648).
impute <- function(p, trend, tol = 1e-6) {
  f <- as.formula(paste(if (trend) "y ~ tw:t" else "y ~ 1", FE_I))
  m <- fepois(f, data = p[twp == 0], notes = FALSE, warn = FALSE, combine.quick = FALSE,
              fixef.tol = tol)
  tr <- p[twp == 1]
  tr[, yhat := predict(m, newdata = tr)]
  # A fixed-effect group dropped for being all zeros has a fitted mean of 0.
  tr[is.na(yhat), yhat := 0]
  tr
}
att <- function(tr) tr[, sum(y) / sum(yhat) - 1]

cases <- CJ(outcome = TRAFFIC, side = c("set", "rise"), sorted = FALSE)
cases[, bin := 0L]

point <- rbindlist(lapply(seq_len(nrow(cases)), function(i) {
  cs <- cases[i]
  p  <- make_panel(ev, days, cs$outcome, cs$bin, cs$side)
  rbindlist(lapply(c(FALSE, TRUE), function(tr_on) {
    tr <- impute(p, tr_on)
    by_season <- tr[, .(att = sum(y) / sum(yhat) - 1, obs = sum(y), cf = sum(yhat)), by = sy]
    data.table(cs, trend = tr_on, att = att(tr), obs = tr[, sum(y)], cf = tr[, sum(yhat)],
               by_season = list(by_season))
  }))
}))

# ── Stratified cluster bootstrap ────────────────────────────────────────────
draw_panel <- function(p, idx_t, idx_c) {
  pick <- c(TREATED[idx_t], CONTROL[idx_c])
  rbindlist(lapply(seq_along(pick), function(k) p[uf == pick[k]][, uf := paste0(uf, "_", k)]))
}
idx <- lapply(seq_len(nrow(cases)), function(i)
  lapply(seq_len(B), function(r) list(t = sample.int(length(TREATED), replace = TRUE),
                                      c = sample.int(length(CONTROL), replace = TRUE))))
boot <- rbindlist(lapply(seq_len(nrow(cases)), function(i) {
  cs <- cases[i]
  p  <- make_panel(ev, days, cs$outcome, cs$bin, cs$side)
  t0 <- Sys.time()
  draws <- parallel::mclapply(idx[[i]], function(d) {
    setFixest_nthreads(1)
    pb <- draw_panel(p, d$t, d$c)
    c(att(impute(pb, FALSE, tol = 1e-4)), att(impute(pb, TRUE, tol = 1e-4)))
  }, mc.cores = CORES)
  # A failed worker returns a try-error instead of two numbers.
  stopifnot(all(vapply(draws, function(x) is.numeric(x) && length(x) == 2L, logical(1))))
  draws <- do.call(rbind, draws)
  stopifnot(nrow(draws) == B)
  message(sprintf("  %s, %s: %d draws in %.1f min", cs$outcome, cs$side, B,
                  as.numeric(difftime(Sys.time(), t0, units = "mins"))))
  data.table(cs, trend = c(FALSE, TRUE),
             se = apply(draws, 2, sd, na.rm = TRUE),
             lo = apply(draws, 2, quantile, 0.025, na.rm = TRUE),
             hi = apply(draws, 2, quantile, 0.975, na.rm = TRUE),
             share_le0 = apply(draws, 2, function(x) mean(x <= 0, na.rm = TRUE)))
}))

res <- boot[point, on = .(outcome, side, bin, trend)]
saveRDS(res, file.path(path_audit, "imputation.rds"))

options(width = 170)
cat(sprintf("Imputation ATT, light-switched hours, seasons %d/%02d-%d/%02d, B = %d\n",
            min(SEASONS), (min(SEASONS) + 1) %% 100, max(SEASONS), (max(SEASONS) + 1) %% 100, B))
print(res[, .(outcome, hour = fifelse(side == "set", "evening bin 0", "morning bin 0"),
              trend = fifelse(trend, "pre-trend extrapolated", "no trend"),
              att_pct = round(100 * att, 1), ci95 = sprintf("[%.1f, %.1f]", 100 * lo, 100 * hi),
              boot_se_pct = round(100 * se, 1), obs = obs, counterfactual = round(cf),
              excess = round(obs - cf))])
cat("\nBy season (evening bin 0, pre-trend extrapolated):\n")
print(rbindlist(lapply(which(res$side == "set" & res$trend), function(i)
  res$by_season[[i]][, .(outcome = res$outcome[i], sy, att_pct = round(100 * att, 1), obs, cf = round(cf))])))
