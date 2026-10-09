# =============================================================================
# 17_inference_volume.R
#
# Inference that does not lean on 23-cluster asymptotics for the PNCT traffic
# volume results of 16_traffic_volume.R, as 07 and 15 do for crashes:
#   (a) wild cluster restricted bootstrap (Webb, B = 9,999) on the linear
#       analogue of the volume triple difference (fixed effects
#       station + uf^window + uf^sy + date partialled out), clusters = UF;
#   (b) permutation inference: draw 11 of the 23 states as "treated" (DS_RI
#       draws, default 999; the treatment was not randomized, so this is a
#       permutation test, not randomization inference), refit the Poisson
#       volume model, and compare |b| with the permutation distribution;
#   (c) risk per vehicle: in each draw the same fake assignment refits the PRF
#       injury-crash model (UF x day, 02/12) and the volume model, so the
#       difference crash - volume has its own null distribution.
# Hours: evening -1, 0, +1 and morning 0 (60-minute bins relative to
# standard-time sunset / sunrise). Reads the station-day x hour panel that 16
# writes (pnct/output/pnct_station_day_bins.parquet).
# Draws run in parallel (DS_CORES, default 5) and are drawn up front, so the
# result does not depend on the number of cores.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(fwildclusterboot)
  library(parallel)
})

N_RI  <- as.integer(Sys.getenv("DS_RI", unset = "999"))
CORES <- as.integer(Sys.getenv("DS_CORES", unset = "5"))
set.seed(20190425)                       # Decree 9,772
dqrng::dqset.seed(20190425)
setFixest_nthreads(1)

ALL  <- c(TREATED, CONTROL)
KEYS <- c("eve-1", "eve+0", "eve+1", "morn+0")
FEV  <- "| station + uf^window + uf^sy + date"
FAKES <- replicate(N_RI, sample(ALL, length(TREATED)), simplify = FALSE)

vol <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "pnct", "output",
                                            "pnct_station_day_bins.parquet")))
vol <- vol[key %in% KEYS]

# PRF injury crashes, UF x day, same hours (as in 12_reallocation.R).
SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
crash_panel <- function(k) {
  side <- if (startsWith(k, "eve")) "set" else "rise"
  make_panel(ev, days, "PRF injury accidents", as.integer(sub("^[a-z]+", "", k)), side)
}

fit_b <- function(p, v, fe) coef(fepois(as.formula(paste("y ~", v, fe)), data = p, notes = FALSE))[[v]]

res <- list()
for (k in KEYS) {
  pv <- vol[key == k]
  pc <- crash_panel(k)

  # (a) wild cluster bootstrap, linear analogue of the volume model
  dm <- as.data.table(demean(pv[, .(y, twp)], f = pv[, .(station, uw = paste(uf, window),
                                                          us = paste(uf, sy), date)]))
  dm[, uf := pv$uf]
  lm_fit <- lm(y ~ twp, data = dm)
  wb <- boottest(lm_fit, param = "twp", clustid = "uf", B = 9999, type = "webb")

  m_vol <- fepois(as.formula(paste("y ~ twp", FEV)), data = pv, cluster = ~uf, notes = FALSE)
  m_cr  <- fepois(as.formula(paste("y ~ twp", FE)), data = pc, cluster = ~uf, notes = FALSE)
  b_vol <- coef(m_vol)[["twp"]]; b_cr <- coef(m_cr)[["twp"]]

  # (b), (c) permutation, same fake assignment for volume and crashes
  t0 <- Sys.time()
  perm <- mclapply(FAKES, function(fake) {
    a <- copy(pv)[, fk := as.integer(uf %in% fake) * win * post]
    b <- copy(pc)[, fk := as.integer(uf %in% fake) * win * post]
    c(vol = fit_b(a, "fk", FEV), crash = fit_b(b, "fk", FE))
  }, mc.cores = CORES)
  perm <- do.call(rbind, perm)
  cat(sprintf("%s: %d draws in %.1f min\n", k, N_RI, as.numeric(difftime(Sys.time(), t0, units = "mins"))))
  d_real <- b_cr - b_vol
  d_perm <- perm[, "crash"] - perm[, "vol"]

  res[[k]] <- data.table(
    bin_key = k,
    vol_lp = 100 * b_vol, vol_cluster_p = pvalue(m_vol)[["twp"]], vol_wcr_p = pval(wb),
    vol_perm_p = mean(abs(perm[, "vol"]) >= abs(b_vol)),
    crash_lp = 100 * b_cr, crash_perm_p = mean(abs(perm[, "crash"]) >= abs(b_cr)),
    per_vehicle_lp = 100 * d_real, per_vehicle_perm_p = mean(abs(d_perm) >= abs(d_real)),
    n_perm = N_RI)
}
res <- rbindlist(res)

saveRDS(res, file.path(path_audit, "inference_volume.rds"))
options(width = 180)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
