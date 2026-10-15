# =============================================================================
# 06_inference.R
#
# Inference that does not lean on 23-cluster asymptotics, for the evening
# light-switched hour (bin 0) and the morning one.
#
#   (a) Wild cluster restricted bootstrap (Webb weights, B = 9,999) on the
#       linear analogue of the main specification: OLS of the UF-day count on
#       treated x window x post with the same three fixed effects, partialled
#       out first (fixest::demean), clusters = UF. The WCR p-value is invariant
#       to the scale of the outcome, so this tests the same null as the Poisson
#       model, in levels.
#   (b) Permutation inference over treatment assignment: draw 11 of the 23
#       states as "treated" (999 draws), re-estimate the Poisson triple
#       difference, and compare |t| (coefficient over its state-clustered
#       standard error) with the permutation distribution of |t| (fit_bs,
#       00_utils.R). A Fisher test of the sharp null of no effect in any state.
#       Draws are made up front and run in parallel (DS_CORES, default 5).
#   (b2) Score wild bootstrap (Kline and Santos 2012) on the Poisson model
#       itself, null imposed: fit the model without the treatment term, take
#       each state's score for it, sum(x~ (y - mu)), where x~ is the treatment
#       indicator net of the fixed effects (weighted by the fitted means), and
#       compare the studentized score with its distribution when each state's
#       score is multiplied by a Webb weight (9,999 draws).
#   (c) Excess-zeros check for the Poisson mean model: observed share of
#       zero cells against the share implied by the fitted means,
#       mean(exp(-mu)). A large gap would call for a two-part model; Poisson
#       PML itself stays consistent as long as the mean is right.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(fwildclusterboot)
})

N_PERM <- as.integer(Sys.getenv("DS_PERM", unset = "999"))
CORES  <- as.integer(Sys.getenv("DS_CORES", unset = "5"))
set.seed(20190425)                       # Decree 9,772
dqrng::dqset.seed(20190425)
setFixest_nthreads(1)

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
ALL  <- c(TREATED, CONTROL)
FAKES <- replicate(N_PERM, sample(ALL, length(TREATED)), simplify = FALSE)

cases <- CJ(outcome = TRAFFIC, side = c("set", "rise"), sorted = FALSE)

res <- rbindlist(lapply(seq_len(nrow(cases)), function(i) {
  cs <- cases[i]
  p  <- make_panel(ev, days, cs$outcome, 0L, cs$side)

  # (a) wild cluster bootstrap on the demeaned linear model
  dm <- as.data.table(demean(p[, .(y, twp)], f = p[, .(uw = paste(uf, window),
                                                       us = paste(uf, sy), date)]))
  dm[, uf := p$uf]
  lm_fit <- lm(y ~ twp, data = dm)   # intercept ~0 after demeaning; boottest needs one
  wb <- boottest(lm_fit, param = "twp", clustid = "uf", B = 9999, type = "webb")
  base_mean <- p[tw == 1 & post == 0, mean(y)]

  # (b2) score wild bootstrap, Poisson, null imposed
  m0 <- fepois(as.formula(paste("y ~ 1", FE)), data = p, notes = FALSE)
  keep <- obs(m0); mu0 <- fitted(m0)
  xt <- demean(p$twp[keep], f = p[keep, .(uw = paste(uf, window), us = paste(uf, sy), date)],
               weights = mu0)[, 1]
  sg <- tapply(xt * (p$y[keep] - mu0), p$uf[keep], sum)
  t_score <- sum(sg) / sqrt(sum(sg^2))
  webb <- c(-sqrt(1.5), -1, -sqrt(0.5), sqrt(0.5), 1, sqrt(1.5))
  t_boot <- replicate(9999, { v <- sample(webb, length(sg), replace = TRUE)
                              sum(v * sg) / sqrt(sum((v * sg)^2)) })
  score_p <- mean(abs(t_boot) >= abs(t_score))

  # (b) permutation inference
  m_real <- fepois(as.formula(paste("y ~ twp", FE)), data = p, notes = FALSE)
  b_real <- coef(m_real)[["twp"]]
  mu <- fitted(m_real)
  y_used <- p$y[obs(m_real)]
  zeros_obs  <- mean(y_used == 0)
  zeros_pois <- mean(exp(-mu))
  t_real <- t_stat(fit_bs(as.formula(paste("y ~ twp", FE)), p, "twp"))
  perm <- unlist(parallel::mclapply(FAKES, function(fake) {
    q <- copy(p)[, fk := as.integer(uf %in% fake) * win * post]
    t_stat(fit_bs(as.formula(paste("y ~ fk", FE)), q, "fk"))
  }, mc.cores = CORES))
  stopifnot(length(perm) == N_PERM, is.numeric(perm))

  data.table(cs, poisson_lp = 100 * b_real,
             linear_effect_pct_of_base = 100 * coef(lm_fit)[["twp"]] / base_mean,
             wcr_p = pval(wb), wcr_ci_pct = sprintf("[%.1f, %.1f]",
                                                    100 * confint(wb)[1] / base_mean,
                                                    100 * confint(wb)[2] / base_mean),
             score_p = score_p,
             perm_p = perm_pvalue(perm, t_real),
             perm_rank = sprintf("%d of %d", sum(abs(perm) >= abs(t_real)), N_PERM),
             zeros_obs_pct = 100 * zeros_obs, zeros_poisson_pct = 100 * zeros_pois,
             dispersion = var(y_used - mu) / mean(mu))
}))

saveRDS(res, file.path(path_audit, "inference.rds"))
options(width = 170)
print(res[, .(outcome, hour = fifelse(side == "set", "evening bin 0", "morning bin 0"),
              poisson_lp = round(poisson_lp, 1),
              linear_pct = round(linear_effect_pct_of_base, 1), wcr_p = round(wcr_p, 4),
              wcr_ci_pct, score_p = round(score_p, 4), perm_p = round(perm_p, 3), perm_rank,
              zeros_obs_pct = round(zeros_obs_pct, 1), zeros_poisson_pct = round(zeros_poisson_pct, 1),
              dispersion = round(dispersion, 2))])
