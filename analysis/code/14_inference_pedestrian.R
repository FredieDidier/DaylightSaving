# =============================================================================
# 14_inference_pedestrian.R
#
# The inference of 06_inference.R for the pedestrian split of 12_mechanism.R,
# evening light-switched hour (bin 0):
#   (a) wild cluster restricted bootstrap (Webb, B = 9,999) on the demeaned
#       linear analogue, for pedestrian and non-pedestrian outcomes;
#   (b) permutation inference over which 11 of the 23 states are treated
#       (DS_PERM draws, default 999), for each coefficient and for the
#       pedestrian - other difference (same fake assignment for both members of
#       a pair in each draw, so the difference has its own null distribution);
#   (c) excess zeros, as in 06. Pedestrian counts are rare (~1 per UF-season
#       in the switched hour), so this matters more here.
# Draws run in parallel (DS_CORES, default 5); fake assignments are drawn up
# front, so the result does not depend on the number of cores.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(fwildclusterboot)
  library(parallel)
})

N_PERM  <- as.integer(Sys.getenv("DS_PERM", unset = "999"))
CORES <- as.integer(Sys.getenv("DS_CORES", unset = "5"))
set.seed(20190425)                       # Decree 9,772
dqrng::dqset.seed(20190425)

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
ALL  <- c(TREATED, CONTROL)
setFixest_nthreads(1)

PAIRS <- list(
  "SIM deaths, on road"  = c(ped = "SIM pedestrian deaths, on road",
                             other = "SIM non-pedestrian deaths, on road"),
  "PRF deaths"           = c(ped = "PRF pedestrian deaths", other = "PRF non-pedestrian deaths"),
  "PRF injury accidents" = c(ped = "PRF pedestrian injury accidents",
                             other = "PRF non-pedestrian injury accidents"))
FAKES <- replicate(N_PERM, sample(ALL, length(TREATED)), simplify = FALSE)

fit_b <- function(p, v) coef(fepois(as.formula(paste("y ~", v, FE)), data = p, notes = FALSE))[[v]]

res <- list()
for (nm in names(PAIRS)) {
  P <- lapply(PAIRS[[nm]], function(o) make_panel(ev, days, o, 0L, "set"))
  out <- rbindlist(lapply(names(P), function(g) {
    p <- P[[g]]
    dm <- as.data.table(demean(p[, .(y, twp)], f = p[, .(uw = paste(uf, window),
                                                         us = paste(uf, sy), date)]))
    dm[, uf := p$uf]
    lm_fit <- lm(y ~ twp, data = dm)
    wb <- boottest(lm_fit, param = "twp", clustid = "uf", B = 9999, type = "webb")
    m  <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf, notes = FALSE)
    mu <- fitted(m); yu <- p$y[obs(m)]
    data.table(pair = nm, group = g, poisson_lp = 100 * coef(m)[["twp"]],
               cluster_p = pvalue(m)[["twp"]], wcr_p = pval(wb),
               zeros_obs_pct = 100 * mean(yu == 0), zeros_poisson_pct = 100 * mean(exp(-mu)),
               dispersion = var(yu - mu) / mean(mu))
  }))
  t0 <- Sys.time()
  perm <- mclapply(FAKES, function(fake) {
    sapply(P, function(p) {
      p <- copy(p)[, fk := as.integer(uf %in% fake) * win * post]
      fit_b(p, "fk")
    })
  }, mc.cores = CORES)
  perm <- do.call(rbind, perm)
  cat(sprintf("%s: %d draws in %.1f min\n", nm, N_PERM, as.numeric(difftime(Sys.time(), t0, units = "mins"))))
  b <- setNames(out$poisson_lp / 100, out$group)
  d_real <- b[["ped"]] - b[["other"]]
  d_perm <- perm[, "ped"] - perm[, "other"]
  out[, perm_p := c(perm_pvalue(perm[, "ped"], b[["ped"]]), perm_pvalue(perm[, "other"], b[["other"]]))]
  out <- rbind(out, data.table(pair = nm, group = "ped - other", poisson_lp = 100 * d_real,
                               perm_p = perm_pvalue(d_perm, d_real)), fill = TRUE)
  res[[nm]] <- out
}
res <- rbindlist(res)
res[, n_perm := N_PERM]

saveRDS(res, file.path(path_audit, "inference_pedestrian.rds"))
options(width = 180)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 4) else x)])
