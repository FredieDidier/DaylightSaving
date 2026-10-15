# =============================================================================
# 16_inference_volume.R
#
# Permutation inference for the traffic-volume table, so that its five columns
# do not lean on 23-cluster asymptotics, as 06 and 14 do for the crash tables.
#
# For each of the seven hours of 15_traffic_volume.R (evening -2 to +1, morning
# -1 to +1; 60-minute bins relative to standard-time sunset and sunrise):
#   vehicles        Poisson volume triple difference on the PNCT station panel,
#                   y[s,d] ~ treated x window x post | station + uf^window +
#                   uf^sy + date
#   injury crashes  PRF crashes with victims, UF x day, as in 01, on the
#                   summers the stations counted (as in 15)
#   deaths          PRF deaths, UF x day, same summers
#   per vehicle     crash estimate minus volume estimate, for each crash outcome
# Each draw picks 11 of the 23 states as "treated" (DS_PERM draws, default
# 999; the treatment was not randomized, so this is a permutation test, not
# randomization inference) and refits all three models under that one
# assignment, so the per-vehicle differences get their own null distribution.
# p = (1 + #{|b_perm| >= |b|}) / (1 + N), as everywhere (perm_pvalue).
#
# Reads the station-day x hour panel that 15 writes
# (pnct/output/pnct_station_day_bins.parquet); the point estimates must equal
# those of 15, and the script stops if they do not. The p-values are printed in
# brackets in tab_traffic_volume (30_tables.R).
#
# Draws run in parallel (DS_CORES, default 5) and are drawn up front, so the
# result does not depend on the number of cores.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(parallel)
})

N_PERM <- as.integer(Sys.getenv("DS_PERM", unset = "999"))
CORES  <- as.integer(Sys.getenv("DS_CORES", unset = "5"))
set.seed(20190425)                       # Decree 9,772
setFixest_nthreads(1)

ALL   <- c(TREATED, CONTROL)
KEYS  <- c("eve-2", "eve-1", "eve+0", "eve+1", "morn-1", "morn+0", "morn+1")
CRASH <- c(injury = "PRF injury accidents", deaths = "PRF deaths")
FEV   <- "| station + uf^window + uf^sy + date"
FAKES <- replicate(N_PERM, sample(ALL, length(TREATED)), simplify = FALSE)

vol <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "pnct", "output",
                                            "pnct_station_day_bins.parquet")))
vol <- vol[key %in% KEYS]

days <- make_days(sort(unique(vol[window == "win", sy])))
ev   <- as.data.table(read_parquet(EVENTS_FILE))
crash_panel <- function(k, outc) {
  side <- if (startsWith(k, "eve")) "set" else "rise"
  make_panel(ev, days, outc, as.integer(sub("^[a-z]+", "", k)), side)
}

fit_p <- function(p, v, fe) fit_bs(as.formula(paste("y ~", v, fe)), p, v)
# t-statistics for one assignment: vehicles, crashes, deaths, and the two
# per-vehicle differences, each studentized (fit_bs, t_diff in 00_utils.R).
stats <- function(bv, bc) c(vehicles = t_stat(bv), injury = t_stat(bc$injury), deaths = t_stat(bc$deaths),
                            injury_pv = t_diff(bc$injury, bv), deaths_pv = t_diff(bc$deaths, bv))

res <- list()
for (k in KEYS) {
  pv <- vol[key == k]
  pc <- lapply(CRASH, function(o) crash_panel(k, o))
  bv <- fit_p(pv, "twp", FEV)
  bc <- lapply(pc, fit_p, v = "twp", fe = FE)
  b  <- c(vehicles = bv[["b"]], sapply(bc, `[[`, "b"))
  s_real <- stats(bv, bc)

  t0 <- Sys.time()
  perm <- do.call(rbind, mclapply(FAKES, function(fake) {
    fk <- function(p) copy(p)[, fk := as.integer(uf %in% fake) * win * post]
    stats(fit_p(fk(pv), "fk", FEV), lapply(pc, function(p) fit_p(fk(p), "fk", FE)))
  }, mc.cores = CORES))
  cat(sprintf("%s: %d draws in %.1f min\n", k, N_PERM,
              as.numeric(difftime(Sys.time(), t0, units = "mins"))))

  res[[k]] <- data.table(
    bin_key = k,
    vehicles_lp = 100 * b[["vehicles"]],
    vehicles_perm_p = perm_pvalue(perm[, "vehicles"], s_real[["vehicles"]]),
    injury_lp = 100 * b[["injury"]],
    injury_perm_p = perm_pvalue(perm[, "injury"], s_real[["injury"]]),
    injury_per_vehicle_perm_p = perm_pvalue(perm[, "injury_pv"], s_real[["injury_pv"]]),
    deaths_lp = 100 * b[["deaths"]],
    deaths_perm_p = perm_pvalue(perm[, "deaths"], s_real[["deaths"]]),
    deaths_per_vehicle_perm_p = perm_pvalue(perm[, "deaths_pv"], s_real[["deaths_pv"]]),
    n_perm = N_PERM)
}
res <- rbindlist(res)

# Guard: the point estimates are those of the table (15_traffic_volume.R).
rk <- readRDS(file.path(path_audit, "traffic_volume.rds"))$risk
chk <- merge(res, rk[outcome == CRASH[["injury"]], .(bin_key, vol_lp, ic_lp = crash_lp)], by = "bin_key")
chk <- merge(chk, rk[outcome == CRASH[["deaths"]], .(bin_key, de_lp = crash_lp)], by = "bin_key")
stopifnot(nrow(chk) == length(KEYS),
          chk[, all(abs(vehicles_lp - vol_lp) < 1e-3 & abs(injury_lp - ic_lp) < 1e-3 &
                    abs(deaths_lp - de_lp) < 1e-3)])

saveRDS(res, file.path(path_audit, "inference_volume.rds"))
options(width = 180)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
