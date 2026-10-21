# =============================================================================
# 00_master_analysis.R
#
# Runs the analysis scripts in order, each in its own R process.
#
# Usage
#   Rscript analysis/code/00_master_analysis.R              # everything
#   Rscript analysis/code/00_master_analysis.R 06 14        # just those two
#   Rscript analysis/code/00_master_analysis.R --from 15    # 15 onwards
#   Rscript analysis/code/00_master_analysis.R --list       # print the order
#
# 01-26 estimate and cache their results in audit/*.rds under DROPBOX_ROOT;
# 27 draws every figure and 28 writes every table from those caches, so a
# change of label or layout reruns only the last two. The order matters in
# five places: 01 writes the event file that most later scripts read, 11
# and 23 must run before 25 (it reads their excess counts), 15 writes the
# station panel that 16 reads, 01 and 09 run before 26 (it reads their
# estimates), and 27-28 run last.
# Any script can still be run on its own once its inputs exist.
#
# Each script gets its own process because several fork a worker pool over a
# large panel, and one session would keep every earlier script's memory alive.
# The slow ones (permutation and bootstrap draws) read their draw counts from
# the environment: DS_PERM (06, 09, 14, 16, 26), DS_BOOT (05) and DS_CORES for
# the number of workers. 09 runs its permutation test only when DS_PERM is set.
#
# The first failure stops the run and its exit status is propagated.
# =============================================================================

STEPS <- c(
  "01_sunset_design.R", "02_switched_hour_event_study.R", "03_prf_clock_check.R",
  "04_pretrends.R", "05_imputation.R", "06_inference.R", "07_honestdid.R",
  "08_wider_window.R", "09_within_day.R", "10_assault_trends.R",
  "11_reallocation.R", "12_mechanism.R", "13_design_descriptives.R",
  "14_inference_pedestrian.R", "15_traffic_volume.R", "16_inference_volume.R",
  "17_bahia_switch.R",
  "18_placebo_hours.R", "19_heaping.R", "20_leave_out.R", "21_road_users.R",
  "22_record_integrity.R", "23_light_dose.R", "24_street_lighting.R",
  "25_total_cost.R", "26_transitions.R",
  "27_figures.R", "28_tables.R")
num <- sub("_.*", "", STEPS)

args <- commandArgs(trailingOnly = TRUE)
if ("--list" %in% args) { cat(STEPS, sep = "\n"); quit(save = "no", status = 0) }

sel <- if (!length(args)) seq_along(STEPS) else if (args[1] == "--from") {
  i <- match(sprintf("%02d", as.integer(args[2])), num)
  if (is.na(i)) stop("--from: no such script: ", args[2])
  i:length(STEPS)
} else {
  i <- match(sprintf("%02d", as.integer(args)), num)
  if (anyNA(i)) stop("no such script: ", paste(args[is.na(i)], collapse = ", "))
  i
}

rscript <- file.path(R.home("bin"), "Rscript")
for (f in STEPS[sel]) {
  message(sprintf("\n==== %s  [%s]", f, format(Sys.time(), "%H:%M:%S")))
  status <- system2(rscript, here::here("analysis", "code", f))
  if (status != 0) {
    message(sprintf("==== %s failed (status %d)", f, status))
    quit(save = "no", status = status)
  }
}
message("\n==== done")
