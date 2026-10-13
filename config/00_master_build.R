# =============================================================================
# 00_master_build.R
#
# Runs the build in order, from the legal calendar to the Mexican crash file,
# each script in its own R process.
#
# Usage
#   Rscript config/00_master_build.R            # every step
#   Rscript config/00_master_build.R 04 08      # just those steps
#
# Before running, set DROPBOX_ROOT in config/config.R. Every step downloads its
# raw data into DROPBOX_ROOT/build/<source>/input or reads it from there, with
# two inputs placed by hand: the Xavier rain NetCDF (weather/input, read by 08)
# and INEGI's ATUS zip (mexico/input/atus_raw, read by 11). README.md lists
# the source of each step.
#
# Order matters in two places: 04 writes the municipal seats that 08 reads,
# and the download steps (02, 06) come before their cleaning steps (03, 07).
# 02, 05, 06 and 10 query remote services and take a while; they resume where
# they stopped.
#
# The first failure stops the run and its exit status is propagated.
# =============================================================================

STEPS <- c(
  "01_dst_calendar.R",      # build/manual/ decrees  -> treatment calendar
  "02_download_prf.R",      # PRF open data          -> prf/input
  "03_clean_prf.R",         # prf/input              -> prf_accidents
  "04_municipal_geo.R",     # geobr                  -> municipal seats, zones
  "05_download_sim.R",      # DATASUS FTP            -> sim_<year>
  "06_download_pnct.R",     # DNIT PNCT API          -> pnct/input
  "07_clean_pnct.R",        # pnct/input             -> pnct_hourly
  "08_xavier_rain.R",       # Xavier NetCDF          -> rain at each seat
  "09_census_lighting.R",   # SIDRA, censobr         -> street lighting
  "10_mexico_geo.R",        # INEGI geo API          -> Mexican seats
  "11_mexico_atus.R",       # INEGI ATUS zip         -> Mexican crashes
  "12_map_boundaries.R")    # geobr, GADM            -> boundaries for the maps
num <- sub("_.*", "", STEPS)

args <- commandArgs(trailingOnly = TRUE)
sel  <- if (!length(args)) seq_along(STEPS) else match(sprintf("%02d", as.integer(args)), num)
if (anyNA(sel)) stop("no such step: ", paste(args[is.na(sel)], collapse = ", "))

rscript <- file.path(R.home("bin"), "Rscript")
for (f in STEPS[sel]) {
  message(sprintf("\n==== %s  [%s]", f, format(Sys.time(), "%H:%M:%S")))
  status <- system2(rscript, here::here("build", f))
  if (status != 0) {
    message(sprintf("==== %s failed (status %d)", f, status))
    quit(save = "no", status = status)
  }
}
message("\n==== done")
