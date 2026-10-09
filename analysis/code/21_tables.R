# =============================================================================
# 21_tables.R
#
# Every table of the paper, written as a LaTeX tabular from the estimates
# cached in audit/*.rds. Nothing is estimated here. Captions and notes live in
# the manuscript (latex/exhibits.tex holds the current drafts).
#
#   tab_descriptives    events per summer, group x window x period       (14)
#   tab_main            the hour that turned dark and the hour that turned
#                       light: estimate, three p-values, baseline        (02, 07)
#   tab_pedestrians     pedestrians against other road users            (13, 15)
#   tab_excess          excess events per summer, evening, morning, day  (12)
#   tab_traffic_volume  vehicles, crashes and crashes per vehicle        (16)
#   tab_robustness      the hour that turned dark under other choices,
#                       and the hours whose light did not change         (05, 06, 09, 10, 19)
#
# Conventions: outcome names as in OUTCOME_LAB (never the data source);
# estimates in log points with the standard error below in parentheses;
# p-values printed, no stars; a true minus sign; no abbreviated headings.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))

rd <- function(f) readRDS(file.path(path_audit, f))
dir.create(path_tables, recursive = TRUE, showWarnings = FALSE)

# ── Formatting ──────────────────────────────────────────────────────────────
minus <- function(s) sub("^-", "$-$", s)
f1  <- function(x) minus(formatC(x, format = "f", digits = 1))
f0  <- function(x) minus(formatC(round(x), format = "d", big.mark = ","))
se1 <- function(x) sprintf("(%s)", formatC(x, format = "f", digits = 1))
se0 <- function(x) sprintf("(%s)", formatC(round(x), format = "d", big.mark = ","))
fp  <- function(p) ifelse(p < 0.001, "$<$0.001", formatC(p, format = "f", digits = 3))
ci1 <- function(lo, hi) sprintf("[%s, %s]", f1(lo), f1(hi))
row <- function(label, cells) paste0(label, " & ", paste(cells, collapse = " & "), " \\\\")
panel <- function(text, ncol) sprintf("\\multicolumn{%d}{@{}l}{\\textit{%s}} \\\\", ncol, text)
write_tab <- function(name, lines) {
  writeLines(lines, file.path(path_tables, paste0(name, ".tex")))
  cat(sprintf("  wrote %s.tex\n", name))
}

# The three traffic outcomes as column heads, on two lines, numbered.
HEAD3 <- c(" & Road & Federal highway & Federal highway \\\\",
           " & deaths & deaths & injury crashes \\\\",
           " & (1) & (2) & (3) \\\\")
open3  <- c("\\begin{tabular}{@{}l ccc@{}}", "\\toprule", HEAD3, "\\midrule")
close_ <- c("\\bottomrule", "\\end{tabular}")
N_PRE <- sum(rd("sunset_design.rds")$seasons <= LAST_PRE)

# ── Table: descriptives ─────────────────────────────────────────────────────
t1 <- rd("table1.rds")
cols <- c("Treated_win_pre", "Treated_win_post", "Treated_off_pre", "Treated_off_post",
          "Control_win_pre", "Control_win_post", "Control_off_pre", "Control_off_post")
D_LAB <- c("SIM transport deaths, on road"  = "Road deaths",
           "SIM pedestrian deaths, on road" = "\\quad of which pedestrians",
           "PRF deaths"                     = "Federal highway deaths",
           "PRF pedestrian deaths"          = "\\quad of which pedestrians",
           "PRF injury accidents"           = "Federal highway injury crashes")
drows <- function(sc) t1[scope == sc, row(D_LAB[as.character(outcome)], sapply(.SD, f0)),
                         by = outcome, .SDcols = cols]$V1
write_tab("tab_descriptives", c(
  "\\begin{tabular}{@{}l rrrr rrrr@{}}", "\\toprule",
  " & \\multicolumn{4}{c}{Treated states} & \\multicolumn{4}{c}{Control states} \\\\",
  "\\cmidrule(lr){2-5}\\cmidrule(l){6-9}",
  paste(" & \\multicolumn{2}{c}{Summer window} & \\multicolumn{2}{c}{Off-season}",
        "& \\multicolumn{2}{c}{Summer window} & \\multicolumn{2}{c}{Off-season} \\\\"),
  "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}\\cmidrule(lr){6-7}\\cmidrule(l){8-9}",
  " & Before & After & Before & After & Before & After & Before & After \\\\",
  "\\midrule",
  panel("Panel A. Whole day", 9), drows("whole day"),
  "\\addlinespace",
  panel("Panel B. Hour after standard-time sunset", 9), drows("evening hour 0"),
  close_))

# ── Table: main estimates ───────────────────────────────────────────────────
sd_ <- rd("sunset_design.rds")$results[outcome %in% TRAFFIC & bin == 0L]
sd_[, side := fifelse(grepl("^evening", side), "set", "rise")]
inf <- rd("inference.rds")
m <- inf[sd_, on = .(outcome, side)]
main_panel <- function(s) {
  x <- m[side == s][match(TRAFFIC, outcome)]
  c(row("Effect of abolition (log points)", f1(100 * x$coef)),
    row("", se1(100 * x$se)),
    row("Change (percent)", f1(x$pct)),
    row("p-value, clustered by state", fp(x$p)),
    row("p-value, permutation of treated states", fp(x$ri_p)),
    row("Linear model: effect (percent of baseline)", f1(x$linear_effect_pct_of_base)),
    row("Linear model: p-value, wild cluster bootstrap", fp(x$wcr_p)),
    row("Events per summer, treated states before abolition", f0(x$n_treated_win_pre / N_PRE)))
}
write_tab("tab_main", c(
  open3,
  panel("Panel A. Evening: hour after standard-time sunset, which turned dark", 4), main_panel("set"),
  "\\addlinespace",
  panel("Panel B. Morning: hour after standard-time sunrise, which turned light", 4), main_panel("rise"),
  close_))

# ── Table: pedestrians ──────────────────────────────────────────────────────
PAIR <- c("SIM deaths, on road", "PRF deaths", "PRF injury accidents")
ip <- rd("inference_pedestrian.rds")
ms <- rd("mechanism.rds")$split[hour == "eve+0"]
pm <- ms[ip, on = .(pair, group)]
ped_panel <- function(g) {
  x <- pm[group == g][match(PAIR, pair)]
  c(row("Effect of abolition (log points)", f1(x$poisson_lp)),
    row("", se1(x$se_lp)),
    row("p-value, clustered by state", fp(x$cluster_p)),
    row("p-value, wild cluster bootstrap", fp(x$wcr_p)),
    row("p-value, permutation of treated states", fp(x$ri_p)),
    row("Events per summer, treated states before abolition", f0(x$pre_per_season)))
}
dx <- pm[group == "ped - other"][match(PAIR, pair)]
pp <- pm[group == "ped"][match(PAIR, pair)]
po <- pm[group == "other"][match(PAIR, pair)]
write_tab("tab_pedestrians", c(
  open3,
  panel("Panel A. Pedestrians", 4), ped_panel("ped"),
  "\\addlinespace",
  panel("Panel B. Other road users", 4), ped_panel("other"),
  "\\addlinespace",
  panel("Panel C. Pedestrians minus other road users", 4),
  row("Difference (log points)", f1(dx$coef_lp)),
  row("", se1(dx$se_lp)),
  row("p-value, clustered by state", fp(dx$p)),
  row("p-value, permutation of treated states", fp(dx$ri_p)),
  "\\addlinespace",
  panel("Panel D. Pedestrian share (percent)", 4),
  row("Of events before abolition", f1(100 * pp$pre_per_season / (pp$pre_per_season + po$pre_per_season))),
  row("Of excess events after abolition", f1(pp$share_of_excess)),
  close_))

# ── Table: excess events per summer ─────────────────────────────────────────
ex <- rd("reallocation.rds")$sums
EX <- c("evening, dark (0, +1)"            = "Two hours after sunset",
        "evening, all (-2 to +1)"          = "Two hours before to two hours after sunset",
        "morning, light (0)"               = "Hour after sunrise",
        "net: evening 0, +1 and morning 0" = "Two hours after sunset and hour after sunrise",
        "net: all seven hours"             = "All seven hours above",
        "whole day (separate model)"       = "Whole day, estimated separately")
ex_rows <- function(keys) unlist(lapply(keys, function(k) {
  x <- ex[sum == k][match(TRAFFIC, outcome)]
  c(row(EX[[k]], f0(x$excess_per_season)), row("", se0(x$se)))
}))
write_tab("tab_excess", c(
  open3,
  panel("Panel A. Evening", 4), ex_rows(names(EX)[1:2]),
  "\\addlinespace",
  panel("Panel B. Morning", 4), ex_rows(names(EX)[3]),
  "\\addlinespace",
  panel("Panel C. Net", 4), ex_rows(names(EX)[4:6]),
  close_))

# ── Table: traffic volume and risk per vehicle ──────────────────────────────
rk <- rd("traffic_volume.rds")$risk
BINS <- c("eve-2" = "Two hours before sunset", "eve-1" = "Hour before sunset",
          "eve+0" = "Hour after sunset", "eve+1" = "Second hour after sunset",
          "morn-1" = "Hour before sunrise", "morn+0" = "Hour after sunrise",
          "morn+1" = "Second hour after sunrise")
vol_rows <- function(b) {
  ic <- rk[bin_key == b & outcome == "PRF injury accidents"]
  de <- rk[bin_key == b & outcome == "PRF deaths"]
  c(row(BINS[[b]], c(f1(ic$vol_lp), f1(ic$crash_lp), f1(ic$per_vehicle_lp),
                     f1(de$crash_lp), f1(de$per_vehicle_lp))),
    row("", c(se1(ic$vol_se), se1(ic$crash_se), se1(ic$per_vehicle_se),
              se1(de$crash_se), se1(de$per_vehicle_se))))
}
write_tab("tab_traffic_volume", c(
  "\\begin{tabular}{@{}l ccc cc@{}}", "\\toprule",
  " & & \\multicolumn{2}{c}{Injury crashes} & \\multicolumn{2}{c}{Deaths} \\\\",
  "\\cmidrule(lr){3-4}\\cmidrule(l){5-6}",
  " & Vehicles & All & Per vehicle & All & Per vehicle \\\\",
  " & (1) & (2) & (3) & (4) & (5) \\\\",
  "\\midrule",
  panel("Panel A. Evening", 6), unlist(lapply(c("eve-2", "eve-1", "eve+0", "eve+1"), vol_rows)),
  "\\addlinespace",
  panel("Panel B. Morning", 6), unlist(lapply(c("morn-1", "morn+0", "morn+1"), vol_rows)),
  close_))

# ── Table: robustness and placebo hours ─────────────────────────────────────
pt <- rd("pretrends.rds")$pretrends[bin == 0L][match(TRAFFIC, outcome)]
wd <- rd("within_day.rds")$pooled[side == "set" & reference == "all" & bin == 0L][match(TRAFFIC, outcome)]
ww <- rd("wider_window.rds")[grepl("^B", window)][match(TRAFFIC, outcome)]
im <- rd("imputation.rds")[side == "set" & bin == 0L]
ph <- rd("placebo_hours.rds")
est_rows <- function(label, b, s) c(row(label, f1(b)), row("", se1(s)))
imp_row <- function(label, tr) {
  x <- im[trend == tr][match(TRAFFIC, outcome)]
  c(row(label, f1(100 * x$att)), row("", ci1(100 * x$lo, 100 * x$hi)))
}
plc <- function(b) ph[block == b][match(TRAFFIC, outcome)]
write_tab("tab_robustness", c(
  open3,
  panel("Panel A. Hour after standard-time sunset (log points)", 4),
  est_rows("Baseline", pt$base_lp, pt$base_se),
  est_rows("With a linear treated $\\times$ summer trend", pt$trend_lp, pt$trend_se),
  est_rows("Without the 2020/21 and 2021/22 seasons", pt$nocovid_lp, pt$nocovid_se),
  est_rows("With state-by-day fixed effects", 100 * wd$coef, 100 * wd$se),
  est_rows("Two hours after sunset", ww$base_lp, ww$base_se),
  row("Seasons before abolition jointly zero, p-value", fp(pt$wald_pre_p)),
  "\\addlinespace",
  panel("Panel B. Imputation estimator, hour after sunset (percent)", 4),
  imp_row("Without a trend", FALSE),
  imp_row("With the pre-abolition trend extrapolated", TRUE),
  "\\addlinespace",
  panel("Panel C. Hours whose light did not change (log points)", 4),
  est_rows("Midday", plc("midday (light unchanged)")$lp, plc("midday (light unchanged)")$se),
  est_rows("Night", plc("night (light unchanged)")$lp, plc("night (light unchanged)")$se),
  close_))
