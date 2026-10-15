# =============================================================================
# 07_honestdid.R
#
# Rambachan & Roth (2023) sensitivity analysis for the light-switched evening
# hour. Input: the Poisson event study by season (reference 2018/19, the last
# DST season; coefficients in log points, vcov clustered by UF). Target: the
# average effect over the five post-abolition seasons.
#
# Two kinds of restriction on how far the post-period violation of parallel
# trends may stray:
#   - Smoothness (DeltaSD): the slope of the violation may change by at most M
#     per season between consecutive seasons, in log units (0.01 = 1 log
#     point). M = 0 is exactly "extrapolate the pre-period linear trend";
#     larger M allows curvature.
#   - Relative magnitudes (DeltaRM): a post-period violation may be at most
#     Mbar times the largest season-to-season violation seen before 2019.
# The breakdown value is the smallest M (or Mbar) at which the robust 95% CI
# includes zero.
#
# Package: HonestDiD (github.com/asheshrambachan/HonestDiD).
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(HonestDiD)
})

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
pre_s  <- SEASONS[SEASONS < LAST_PRE]
post_s <- SEASONS[SEASONS > LAST_PRE]
l_avg  <- rep(1 / length(post_s), length(post_s))

M_GRID    <- c(0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.10)
MBAR_GRID <- c(0, 0.25, 0.5, 0.75, 1, 1.5, 2)

breakdown <- function(tab, col) {
  inc0 <- tab[lb <= 0 & ub >= 0]
  if (nrow(inc0)) min(inc0[[col]]) else NA_real_
}

out <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L)
  m <- fepois(as.formula(paste("y ~ i(sy, tw, ref = LAST_PRE)", FE)), data = p, cluster = ~uf)
  keep <- paste0("sy::", c(pre_s, post_s), ":tw")
  stopifnot(all(keep %in% names(coef(m))))
  b <- coef(m)[keep]
  V <- vcov(m)[keep, keep]

  orig <- as.data.table(constructOriginalCS(betahat = b, sigma = V,
                                            numPrePeriods = length(pre_s),
                                            numPostPeriods = length(post_s), l_vec = l_avg))
  sd <- as.data.table(createSensitivityResults(betahat = b, sigma = V,
                                               numPrePeriods = length(pre_s),
                                               numPostPeriods = length(post_s),
                                               Mvec = M_GRID, l_vec = l_avg))
  rm_ <- as.data.table(createSensitivityResults_relativeMagnitudes(
    betahat = b, sigma = V, numPrePeriods = length(pre_s), numPostPeriods = length(post_s),
    Mbarvec = MBAR_GRID, l_vec = l_avg))

  rbind(orig[, .(outcome = o, restriction = "original", param = NA_real_, lb, ub)],
        sd[,  .(outcome = o, restriction = "smoothness (M)", param = M, lb, ub)],
        rm_[, .(outcome = o, restriction = "relative magnitude (Mbar)", param = Mbar, lb, ub)])[
    , `:=`(avg_post_lp = 100 * sum(l_avg * b[paste0("sy::", post_s, ":tw")]),
           breakdown_M = breakdown(sd, "M"), breakdown_Mbar = breakdown(rm_, "Mbar"))][]
}))

saveRDS(out, file.path(path_audit, "honestdid.rds"))

# Figure: drawn by 28_figures.R from the cache saved above.

options(width = 160)
print(out[, .(outcome, restriction, param, lb_lp = round(100 * lb, 1), ub_lp = round(100 * ub, 1),
              avg_post_lp = round(avg_post_lp, 1), breakdown_M, breakdown_Mbar)])
