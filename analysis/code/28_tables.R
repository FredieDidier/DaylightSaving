# =============================================================================
# 28_tables.R
#
# Every table of the paper, written as a LaTeX tabular from the estimates
# cached in audit/*.rds. Nothing is estimated here. Captions and notes live in
# the manuscript (latex/sections/body.tex and appendix_body.tex).
#
#   tab_descriptives    events per summer, group x window x period       (13)
#   tab_main            the hour that turned dark and the hour that turned
#                       light: estimate, three p-values, baseline        (01, 06)
#   tab_pedestrians     pedestrians against other road users            (12, 14)
#   tab_dose            darkness as a dose, from the sun: a fully dark
#                       evening and morning hour, four sets of effects     (23)
#   tab_excess          excess events per summer: dose model, then hour by
#                       hour, evening, morning, day; then the events the
#                       change in traffic alone implies              (23, 11, 25)
#   tab_traffic_volume  vehicles, crashes and crashes per vehicle        (15, 16)
#   tab_within_group    hour 0 against hours of the same state-day, treated
#                       and control states each alone                     (09, 15)
#   tab_measurement     the time of death and the hour it falls in: death
#                       and crash times, the records, heaping, the window
#                       moved, heaped times spread or dropped        (19, 22)
#   tab_robustness      the hour that turned dark under other choices,
#                       and the hours whose light did not change  (04, 05, 08, 09, 18, 20)
#   tab_sensitivity     the hour after sunset under other samples, places,
#                       days and weather                              (04, 20, 23)
#   tab_window_parts    the hour after sunset in parts of the window  (20)
#   tab_traffic_parts   federal highway traffic in parts of the window  (15)
#   tab_transitions     the clock changes before 2019 against abolition  (26)
#   tab_road_users      who dies: road user, pedestrian age and sex, day (21)
#   tab_sex_age         sex and age of the dead, road deaths and federal
#                       highway deaths                                    (21)
#   tab_street_lighting darker against better-lit municipalities          (24)
#   tab_cost            deaths per summer and their value                 (25)
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
f1  <- function(x) minus(formatC(x, format = "f", digits = 1, big.mark = ","))
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
    row("$p$-value, clustered by state", fp(x$p)),
    row("$p$-value, permutation of treated states", fp(x$perm_p)),
    row("$p$-value, score wild bootstrap", fp(x$score_p)),
    row("Linear model: effect (percent of pre-abolition mean)", f1(x$linear_effect_pct_of_base)),
    row("Linear model: $p$-value, wild cluster bootstrap", fp(x$wcr_p)),
    row("Mean events per summer, treated states before abolition", f0(x$n_treated_win_pre / N_PRE)),
    row("Observations (state-days)", f0(x$nobs)))
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
    row("$p$-value, clustered by state", fp(x$cluster_p)),
    row("$p$-value, wild cluster bootstrap", fp(x$wcr_p)),
    row("$p$-value, permutation of treated states", fp(x$perm_p)),
    row("Mean events per summer, treated states before abolition", f0(x$pre_per_season)))
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
  row("$p$-value, clustered by state", fp(dx$p)),
  row("$p$-value, permutation of treated states", fp(dx$perm_p)),
  "\\addlinespace",
  panel("Panel D. Pedestrian share (percent)", 4),
  row("Of events before abolition", f1(100 * pp$pre_per_season / (pp$pre_per_season + po$pre_per_season))),
  row("Of excess events after abolition", f1(pp$share_of_excess)),
  row("", se1(pp$share_se)),
  close_))

# ── Table: darkness as a dose ───────────────────────────────────────────────
dz <- rd("light_dose.rds")$dose
DZ <- c(clock_blind = "Date effects only",
        main        = "Clock hour by date effects (baseline)",
        within_day  = "Adding state-by-day effects",
        hour_free   = "Adding an effect per clock hour, treated states after 2019")
dz_rows <- function(sp, col, secol) {
  x <- dz[spec == sp][match(TRAFFIC, outcome)]
  c(row(DZ[[sp]], f1(x[[col]])), row("", se1(x[[secol]])))
}
dmain <- dz[spec == "main"][match(TRAFFIC, outcome)]
di <- rd("light_dose.rds")$inference[match(TRAFFIC, outcome)]
write_tab("tab_dose", c(
  open3,
  panel("Panel A. Evening clock hour, from full daylight to night (log points)", 4),
  unlist(lapply(names(DZ), dz_rows, col = "evening_lp", secol = "evening_se")),
  row("Baseline: $p$-value, clustered by state", fp(2 * pnorm(-abs(dmain$evening_lp / dmain$evening_se)))),
  row("Baseline: $p$-value, permutation of treated states", fp(di$evening_perm_p)),
  row("Baseline: $p$-value, score wild bootstrap", fp(di$evening_score_p)),
  "\\addlinespace",
  panel("Panel B. Morning clock hour, from full daylight to night (log points)", 4),
  dz_rows("main", "morning_lp", "morning_se"),
  row("Evening equals morning, $p$-value, clustered by state", fp(dmain$diff_p)),
  row("Evening equals morning, $p$-value, permutation", fp(di$diff_perm_p)),
  close_))

# ── Table: excess events per summer ─────────────────────────────────────────
ex <- rd("reallocation.rds")$sums
exh <- rd("reallocation.rds")$hours[hour == "eve+0"][match(TRAFFIC, outcome)]
EX <- c("evening, dark (0, +1)"            = "Two hours after sunset",
        "morning, light (0)"               = "Hour after sunrise",
        "net: evening 0, +1 and morning 0" = "Two hours after sunset and hour after sunrise",
        "net: -1 to +1 at both ends"       = "Hours $-1$ to $+1$ around sunset and sunrise",
        # The seven hours of 11_reallocation.R: two before to two after sunset,
        # one before to two after sunrise (listed in the table note).
        "net: all seven hours"             = "Seven hours around sunset and sunrise",
        "whole day (separate model)"       = "Whole day, estimated separately")
ex_rows <- function(keys) unlist(lapply(keys, function(k) {
  x <- ex[sum == k][match(TRAFFIC, outcome)]
  c(row(EX[[k]], f0(x$excess_per_season)), row("", se0(x$se)))
}))
im <- rd("total_cost.rds")$implied
im_rows <- function(h, label) {
  x <- im[hours == h][match(TRAFFIC, outcome)]
  c(row(label, f0(x$implied_per_season)), row("", se0(x$se)))
}
write_tab("tab_excess", c(
  open3,
  panel("Panel A. Darkness dose model: every hour, weighted by its change in light", 4),
  row("Net, summer window", f0(dmain$net)), row("", se0(dmain$net_se)),
  row("\\quad $p$-value, clustered by state", fp(2 * pnorm(-abs(dmain$net / dmain$net_se)))),
  row("\\quad $p$-value, permutation of treated states", fp(di$net_perm_p)),
  row("\\quad of which evening hours", f0(dmain$evening)),
  row("\\quad of which morning hours", f0(dmain$morning)),
  row("Net, whole DST season (2017 rule)", f0(dmain$season_net)), row("", se0(dmain$season_net_se)),
  row("\\quad effect by part of the window", f0(dmain$season_net_term)), row("", se0(dmain$season_net_term_se)),
  "\\addlinespace",
  panel("Panel B. Hour by hour", 4),
  row("Hour after sunset", f0(exh$excess_per_season)), row("", se0(exh$excess_se)),
  ex_rows(names(EX)),
  "\\addlinespace",
  panel("Panel C. Implied by the change in traffic alone, at an unchanged risk per vehicle", 4),
  im_rows("light unchanged", "Hours whose light did not change"),
  im_rows("light changed", "Hours whose light changed"),
  close_))

# ── Table: traffic volume and risk per vehicle ──────────────────────────────
tv <- rd("traffic_volume.rds")
rk <- tv$risk; pr <- tv$paired
iv <- rd("inference_volume.rds")
pb <- function(p) sprintf("[%s]", fp(p))
BINS <- c("eve-2" = "Two hours before sunset", "eve-1" = "Hour before sunset",
          "eve+0" = "Hour after sunset", "eve+1" = "Second hour after sunset",
          "morn-1" = "Hour before sunrise", "morn+0" = "Hour after sunrise",
          "morn+1" = "Second hour after sunrise")
vol_rows <- function(b) {
  ic <- rk[bin_key == b & outcome == "PRF injury accidents"]
  de <- rk[bin_key == b & outcome == "PRF deaths"]
  pa <- pr[bin_key == b]
  c(row(BINS[[b]], c(f1(ic$vol_lp), f1(pa$coef_lp), f1(ic$crash_lp), f1(ic$per_vehicle_lp),
                     f1(de$crash_lp), f1(de$per_vehicle_lp))),
    row("", c(se1(ic$vol_se), se1(pa$se_lp), se1(ic$crash_se), se1(ic$per_vehicle_se),
              se1(de$crash_se), se1(de$per_vehicle_se))),
    with(iv[bin_key == b],
         row("", c(pb(vehicles_perm_p), "", pb(injury_perm_p), pb(injury_per_vehicle_perm_p),
                   pb(deaths_perm_p), pb(deaths_per_vehicle_perm_p)))))
}
write_tab("tab_traffic_volume", c(
  "\\begin{tabular}{@{}l cc cc cc@{}}", "\\toprule",
  " & \\multicolumn{2}{c}{Vehicles} & \\multicolumn{2}{c}{Injury crashes} & \\multicolumn{2}{c}{Deaths} \\\\",
  "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}\\cmidrule(l){6-7}",
  " & All stations & Relocated pairs & All & Per vehicle & All & Per vehicle \\\\",
  " & (1) & (2) & (3) & (4) & (5) & (6) \\\\",
  "\\midrule",
  panel("Panel A. Evening", 7), unlist(lapply(c("eve-2", "eve-1", "eve+0", "eve+1"), vol_rows)),
  "\\addlinespace",
  panel("Panel B. Morning", 7), unlist(lapply(c("morn-1", "morn+0", "morn+1"), vol_rows)),
  close_))

# ── Table: within the day, each group alone ─────────────────────────────────
wg <- rd("within_day.rds")$by_group[bin == 0L]
vg <- rd("traffic_volume.rds")$by_group[bin == 0L]
wg_rows <- function(s, g) {
  x <- wg[side == s & group == g][match(TRAFFIC, outcome)]
  v <- vg[side == s & group == g]
  stopifnot(nrow(v) == 1L, !anyNA(x$coef))
  c(row(if (g == "treated") "Treated states" else "Control states", f1(c(100 * x$coef, v$coef_lp))),
    row("", se1(c(100 * x$se, v$se_lp))))
}
write_tab("tab_within_group", c(
  "\\begin{tabular}{@{}l cccc@{}}", "\\toprule",
  " & Road & Federal highway & Federal highway & \\\\",
  " & deaths & deaths & injury crashes & Vehicles \\\\",
  " & (1) & (2) & (3) & (4) \\\\",
  "\\midrule",
  panel("Panel A. Hour after standard-time sunset, which turned dark", 5),
  wg_rows("set", "treated"), wg_rows("set", "control"),
  "\\addlinespace",
  panel("Panel B. Hour after standard-time sunrise, which turned light", 5),
  wg_rows("rise", "treated"), wg_rows("rise", "control"),
  close_))

# ── Table: robustness and placebo hours ─────────────────────────────────────
pt <- rd("pretrends.rds")$pretrends[bin == 0L][match(TRAFFIC, outcome)]
wd <- rd("within_day.rds")$pooled[side == "set" & reference == "all" & bin == 0L][match(TRAFFIC, outcome)]
ww <- rd("wider_window.rds")[grepl("^B", window)][match(TRAFFIC, outcome)]
im <- rd("imputation.rds")[side == "set" & bin == 0L]
ph <- rd("placebo_hours.rds")
lo <- rd("leave_out.rds")
est_rows <- function(label, b, s) c(row(label, f1(b)), row("", se1(s)))
imp_row <- function(label, tr) {
  x <- im[trend == tr][match(TRAFFIC, outcome)]
  c(row(label, f1(100 * x$att)), row("", ci1(100 * x$lo, 100 * x$hi)))
}
plc <- function(b) ph[block == b][match(TRAFFIC, outcome)]
ck <- lo[kind == "clock"][match(TRAFFIC, outcome)]
write_tab("tab_robustness", c(
  open3,
  panel("Panel A. Trends and timing (log points)", 4),
  est_rows("Baseline", pt$base_lp, pt$base_se),
  est_rows("With a linear treated $\\times$ summer trend", pt$trend_lp, pt$trend_se),
  est_rows("Without March 2020 to February 2022", pt$nopandemic_lp, pt$nopandemic_se),
  est_rows("First two summers without DST", pt$early_lp, pt$early_se),
  est_rows("Last three summers without DST", pt$late_lp, pt$late_se),
  est_rows("Summer window only (no off-season)", pt$summer_dd_lp, pt$summer_dd_se),
  row("Seasons before abolition equal, $p$-value", fp(pt$wald_pre_p)),
  "\\addlinespace",
  panel("Panel B. Imputation estimator (percent)", 4),
  imp_row("Without a trend", FALSE),
  imp_row("With the pre-abolition trend extrapolated", TRUE),
  "\\addlinespace",
  panel("Panel C. Other comparisons (log points)", 4),
  est_rows("Control states at the treated states' clock time", ck$lp, ck$se),
  est_rows("With state-by-day fixed effects", 100 * wd$coef, 100 * wd$se),
  est_rows("Two hours after sunset", ww$base_lp, ww$base_se),
  "\\addlinespace",
  panel("Panel D. Hours whose light did not change (log points)", 4),
  est_rows("Midday", plc("midday (light unchanged)")$lp, plc("midday (light unchanged)")$se),
  est_rows("Night", plc("night (light unchanged)")$lp, plc("night (light unchanged)")$se),
  close_))

# ── Table: measuring the time of death ──────────────────────────────────────
ri <- rd("record_integrity.rds")
hs <- rd("heaping.rds")$heap_share[match(TRAFFIC, outcome)]
hpm <- rd("heaping.rds")$results
lnk <- ri$link
shift_row <- function(m) {
  x <- hpm[variant == "shift" & shift_min == m][match(TRAFFIC, outcome)]
  lab <- if (m < 0) sprintf("Window starting %d minutes earlier", -m) else sprintf("Window starting %d minutes later", m)
  c(row(lab, f1(x$lp)), row("", se1(x$se)))
}
mv <- function(v) hpm[variant == v & shift_min == 0L][match(TRAFFIC, outcome)]
write_tab("tab_measurement", c(
  "\\begin{tabular}{@{}l ccc@{}}", "\\toprule",
  panel("Panel A. Death and crash times, death registry (percent of pairs)", 4),
  " & & Seven days later & \\\\",
  " & Same date & (chance) & \\\\",
  "\\cmidrule(lr){2-2}\\cmidrule(lr){3-3}",
  row("Death in the hour after the crash",
      c(f1(lnk[pairing == "same date"]$within_0_60_pct), f1(lnk[pairing != "same date"]$within_0_60_pct), "")),
  row("Death within 30 minutes of the crash",
      c(f1(lnk[pairing == "same date"]$within_30_pct), f1(lnk[pairing != "same date"]$within_30_pct), "")),
  row("Pairs", c(f0(lnk[pairing == "same date"]$pairs), f0(lnk[pairing != "same date"]$pairs), "")),
  "\\addlinespace",
  panel("Panel B. Records and abolition, death registry", 4),
  " & Mean & Change after abolition & \\\\",
  " & (percent) & (percentage points) & \\\\",
  "\\cmidrule(lr){2-2}\\cmidrule(lr){3-3}",
  row("Share of land-transport deaths on the road",
      c(f1(ri$test[measure == "on_road"]$mean_pct), f1(ri$test[measure == "on_road"]$pp), "")),
  row("", c("", se1(ri$test[measure == "on_road"]$se_pp), "")),
  row("Share of road deaths without a clock time",
      c(f1(ri$test[measure == "no_time"]$mean_pct), f1(ri$test[measure == "no_time"]$pp), "")),
  row("", c("", se1(ri$test[measure == "no_time"]$se_pp), "")),
  row("Pedestrians among deaths without a clock time",
      c(f1(ri$test[measure == "ped_no_time"]$mean_pct), f1(ri$test[measure == "ped_no_time"]$pp), "")),
  row("", c("", se1(ri$test[measure == "ped_no_time"]$se_pp), "")),
  row("Pedestrians among deaths with a clock time",
      c(f1(ri$test[measure == "ped_time"]$mean_pct), f1(ri$test[measure == "ped_time"]$pp), "")),
  row("", c("", se1(ri$test[measure == "ped_time"]$se_pp), "")),
  "\\midrule", HEAD3, "\\midrule",
  panel("Panel C. Times on the hour or half hour (percent of events)", 4),
  row("On the hour", f1(hs$full_hour_pct)),
  row("On the half hour", f1(hs$half_hour_pct)),
  "\\addlinespace",
  panel("Panel D. Hour after sunset (log points)", 4),
  c(row("Baseline", f1(mv("shift")$lp)), row("", se1(mv("shift")$se))),
  unlist(lapply(c(-15L, -10L, -5L, 5L, 10L, 15L), shift_row)),
  c(row("Rounded times spread over 30 minutes", f1(mv("spread :00 and :30")$lp)),
    row("", se1(mv("spread :00 and :30")$se))),
  c(row("Without rounded times", f1(mv("drop :00 and :30")$lp)),
    row("", se1(mv("drop :00 and :30")$se))),
  c(row("Sunset from the full NOAA solar algorithm", f1(mv("Meeus solar algorithm")$lp)),
    row("", se1(mv("Meeus solar algorithm")$se))),
  close_))

# ── Table: sensitivity of the hour after sunset ─────────────────────────────
hp <- rd("heaping.rds")$results
ld <- rd("light_dose.rds")
sens_row <- function(label, x) c(row(label, f1(x$lp)), row("", se1(x$se)))
pick_h <- function(v) hp[variant == v & shift_min == 0L][match(TRAFFIC, outcome)]
pick_l <- function(k, d) lo[kind == k & dropped == d][match(TRAFFIC, outcome)]
rc <- ld$rain[match(TRAFFIC, outcome)]
write_tab("tab_sensitivity", c(
  open3,
  sens_row("Baseline", pick_h("shift")),
  "\\addlinespace",
  panel("Panel A. Comparison states, places, seasons, and days", 4),
  sens_row("Control states: Northeast only", pick_l("control", "North (control = Northeast only)")),
  sens_row("Control states: North only", pick_l("control", "Northeast (control = North only)")),
  sens_row("Without the coastal municipalities", pick_l("places", "coastal municipalities")),
  sens_row("Without the La Ni\\~na summers, 2020/21 to 2022/23", pick_l("seasons", "La Nina summers 2020/21-2022/23")),
  sens_row("Without 2019/20, the first summer without DST", pick_l("seasons", "2019/20")),
  sens_row("Without Carnival and the year-end holidays", pick_l("days", "Carnival and year-end holidays")),
  c(row("Summer window only, first two summers without DST", f1(pt$summer_early_lp)),
    row("", se1(pt$summer_early_se))),
  c(row("Summer window only, last three summers without DST", f1(pt$summer_late_lp)),
    row("", se1(pt$summer_late_se))),
  c(row("Without March 2020 to February 2022, first summer", f1(pt$early_nopan_lp)),
    row("", se1(pt$early_nopan_se))),
  c(row("Without March 2020 to February 2022, last two summers", f1(pt$late_nopan_lp)),
    row("", se1(pt$late_nopan_se))),
  "\\addlinespace",
  panel("Panel B. Weather", 4),
  c(row("Controlling for the share of the state under rain", f1(rc$with_rain_control_lp)),
    row("", se1(rc$with_rain_control_se))),
  c(row("Effect on a dry state-day", f1(rc$effect_dry_lp)), row("", se1(rc$effect_dry_se))),
  c(row("Change, dry to fully rainy state-day", f1(rc$rain_change_lp)), row("", se1(rc$rain_change_se))),
  close_))

# ── Table: parts of the summer window ───────────────────────────────────────
write_tab("tab_window_parts", c(
  open3,
  panel("Panel A. School weeks and December 24 to January 15", 4),
  sens_row("November 15 to December 7, school weeks", pick_l("school", "school weeks")),
  sens_row("December 24 to January 15", pick_l("school", "school holidays")),
  sens_row("School weeks minus December 24 to January 15", pick_l("school", "school weeks minus holidays")),
  sens_row("\\quad without Par\\'a", pick_l("school", "school weeks minus holidays, without Para")),
  sens_row("\\quad without the coastal municipalities", pick_l("school", "school weeks minus holidays, without the coast")),
  sens_row("\\quad placebo before abolition", pick_l("school", "school weeks minus holidays, placebo 2014")),
  "\\addlinespace",
  panel("Panel B. The other days of the window", 4),
  sens_row("December 8 to 23", pick_l("school", "8 to 23 December")),
  sens_row("January 16 to 31, school break", pick_l("school", "16 to 31 January")),
  sens_row("\\quad without Goi\\'as", pick_l("school", "16 to 31 January, without Goias")),
  sens_row("February 1 to 14", pick_l("school", "1 to 14 February")),
  sens_row("January 16 to 31 minus December 24 to January 15", pick_l("school", "16 to 31 January minus holidays")),
  sens_row("\\quad placebo before abolition", pick_l("school", "16 to 31 January minus holidays, placebo 2014")),
  close_))

# ── Table: traffic in parts of the summer window ────────────────────────────
tp <- tv$parts
TPW <- c("hour 0, all vehicles", "hour 0, heavy vehicles", "whole day, all vehicles")
TPP <- c(school = "November 15 to December 7, school weeks", holiday = "December 24 to January 15",
         jan = "January 16 to 31, school break",
         "school minus holiday" = "School weeks minus December 24 to January 15")
write_tab("tab_traffic_parts", c(
  "\\begin{tabular}{@{}l ccc@{}}", "\\toprule",
  " & \\multicolumn{2}{c}{Hour after sunset} & Whole day \\\\",
  "\\cmidrule(lr){2-3}\\cmidrule(l){4-4}",
  " & All vehicles & Heavy vehicles & All vehicles \\\\",
  " & (1) & (2) & (3) \\\\", "\\midrule",
  unlist(lapply(names(TPP), function(k) {
    x <- tp[part == k][match(TPW, what)]
    c(row(TPP[[k]], f1(x$coef_lp)), row("", se1(x$se_lp)))
  })),
  close_))

# ── Table: who dies (road deaths only) ──────────────────────────────────────
ru_all <- rd("road_users.rds")$results
ru <- ru_all[outcome == "SIM transport deaths, on road"]
RU <- list(
  list("Panel A. Road user", "road user",
       c(pedestrian = "Pedestrians", motorcyclist = "Motorcyclists",
         `car or light vehicle` = "Car and light-vehicle occupants", other = "Other road users",
         cyclist = "Cyclists")),
  list("Panel B. Pedestrians by age and sex", c("pedestrian age", "pedestrian sex"),
       c(`15-64` = "Aged 15 to 64", `65+` = "Aged 65 or over", `0-14` = "Aged under 15",
         male = "Men", female = "Women")),
  list("Panel C. Day", c("day", "day, pedestrians"),
       c(`working day` = "Weekdays", `weekend or holiday` = "Weekends and holidays")))
ru_rows <- function(sp, lab, prefix = "") unlist(lapply(names(lab), function(g) {
  x <- ru[split %in% sp & group == g]
  if (nrow(x) == 0) return(NULL)
  x <- x[1]
  if (!x$estimable) return(row(paste0(prefix, lab[[g]]), c("--", "--", "--", f1(x$pre_per_season))))
  row(paste0(prefix, lab[[g]]), c(f1(x$lp), sprintf("(%s)", formatC(x$se, format = "f", digits = 1)),
                                  fp(x$p), f1(x$pre_per_season)))
}))
allr <- ru[split == "all"]
write_tab("tab_road_users", c(
  "\\begin{tabular}{@{}l cccc@{}}", "\\toprule",
  " & Effect & Standard & & Mean deaths per summer, \\\\",
  " & (log points) & error & $p$-value & treated states before \\\\",
  "\\midrule",
  row("All road deaths", c(f1(allr$lp), sprintf("(%s)", formatC(allr$se, format = "f", digits = 1)),
                           fp(allr$p), f1(allr$pre_per_season))),
  "\\addlinespace", panel(RU[[1]][[1]], 5), ru_rows(RU[[1]][[2]], RU[[1]][[3]]),
  "\\addlinespace", panel(RU[[2]][[1]], 5), ru_rows(RU[[2]][[2]], RU[[2]][[3]]),
  "\\addlinespace", panel(RU[[3]][[1]], 5), ru_rows("day", RU[[3]][[3]]),
  ru_rows("day", c(`weekend or holiday, without Carnival and year-end` =
                     "\\quad without Carnival and year-end")),
  ru_rows("day, pedestrians", setNames(paste("Pedestrians,", tolower(RU[[3]][[3]])), names(RU[[3]][[3]]))),
  close_))

# ── Table: sex and age of the dead, both sources ──────────────────────────
SA <- c(male = "Men", female = "Women", `0-14` = "Aged under 15", `15-29` = "Aged 15 to 29",
        `30-44` = "Aged 30 to 44", `45-59` = "Aged 45 to 59", `60+` = "Aged 60 or over",
        unknown = "Age not recorded")
sa_cells <- function(x) if (!x$estimable || is.na(x$lp)) c("--", "--", "--", f1(x$pre_per_season)) else
  c(f1(x$lp), sprintf("(%s)", formatC(x$se, format = "f", digits = 1)), fp(x$p), f1(x$pre_per_season))
sa_row <- function(label, sp, g) {
  x <- lapply(TRAFFIC[1:2], function(o) ru_all[outcome == o & split == sp & group == g])
  stopifnot(all(sapply(x, nrow) == 1L))
  row(label, c(sa_cells(x[[1]]), sa_cells(x[[2]])))
}
write_tab("tab_sex_age", c(
  "\\begin{tabular}{@{}l cccc cccc@{}}", "\\toprule",
  " & \\multicolumn{4}{c}{Road deaths} & \\multicolumn{4}{c}{Federal highway deaths} \\\\",
  "\\cmidrule(lr){2-5}\\cmidrule(l){6-9}",
  paste(" & Effect & Standard & & Deaths per & Effect & Standard & & Deaths per \\\\"),
  paste(" & (log points) & error & $p$-value & summer & (log points) & error & $p$-value & summer \\\\"),
  "\\midrule",
  sa_row("All", "all", "all"),
  "\\addlinespace", panel("Panel A. Sex", 9),
  unlist(lapply(c("male", "female"), function(g) sa_row(SA[[g]], "sex", g))),
  "\\addlinespace", panel("Panel B. Age", 9),
  unlist(lapply(c("0-14", "15-29", "30-44", "45-59", "60+", "unknown"), function(g) sa_row(SA[[g]], "age", g))),
  close_))

# ── Table: street lighting ──────────────────────────────────────────────────
sl <- rd("street_lighting.rds")$results
SLO <- c("SIM transport deaths, on road", "SIM pedestrian deaths, on road", "PRF injury accidents")
sl_rows <- function(b, meas = "unlit_pct_2022") {
  x <- sl[bin == b & measure == meas][match(SLO, outcome)]
  c(row("Above the median (darker streets)", f1(x$dark_lp)), row("", se1(x$dark_se)),
    row("Below the median (better-lit streets)", f1(x$lit_lp)), row("", se1(x$lit_se)),
    row("Difference, $p$-value", fp(x$diff_p)))
}
write_tab("tab_street_lighting", c(
  "\\begin{tabular}{@{}l ccc@{}}", "\\toprule",
  " & Road & Pedestrian & Federal highway \\\\",
  " & deaths & road deaths & injury crashes \\\\",
  " & (1) & (2) & (3) \\\\",
  "\\midrule",
  panel("Panel A. Hour after sunset, Census 2022 (log points)", 4), sl_rows(0L),
  "\\addlinespace",
  panel("Panel B. Hour before sunset, sun lower, Census 2022 (log points)", 4), sl_rows(-1L),
  "\\addlinespace",
  panel("Panel C. Hour after sunset, Census 2010 (log points)", 4), sl_rows(0L, "unlit_pct_2010"),
  close_))

# ── Table: deaths and their value per summer ────────────────────────────────
tc <- rd("total_cost.rds")
CNT <- c("A on road, with clock time", "B on road", "C all transport deaths")
DN <- c("dose model, summer window" = "Summer window, November 15 to February 14",
        "dose model, DST season (2017 rule)" = "Whole DST season, 2017 rule")
RULE <- c("(a) elasticity 1.5 from the US ratio of 160" = "VSL, income elasticity 1.5 (reference)",
          "(c) 100 x GNI per capita" = "VSL, 100 $\\times$ income per head",
          "(b) 160 x GNI per capita" = "VSL, 160 $\\times$ income per head",
          "(d) IPEA social cost of a death (human capital)" = "Ipea social cost of a death")
vl <- tc$value[sum == "dose model, summer window"]
vs <- tc$value[sum == "dose model, DST season (2017 rule)" & rule == names(RULE)[1]][match(CNT, count)]
write_tab("tab_cost", c(
  "\\begin{tabular}{@{}l ccc@{}}", "\\toprule",
  " & Road deaths with & All road & All transport \\\\",
  " & a clock time & deaths & deaths \\\\",
  " & (1) & (2) & (3) \\\\",
  "\\midrule",
  panel("Panel A. Excess deaths", 4),
  unlist(lapply(names(DN), function(k) {
    x <- tc$deaths[sum == k][match(CNT, count)]
    c(row(DN[[k]], f0(x$deaths)), row("", se0(x$se)))
  })),
  row("Share of summer-window transport deaths (percent)",
      f1(tc$deaths[sum == names(DN)[1]][match(CNT, count)]$share_of_summer_transport_deaths_pct)),
  "\\addlinespace",
  panel("Panel B. Value per summer window (millions of 2025 international dollars)", 4),
  unlist(lapply(names(RULE), function(r) {
    x <- vl[rule == r][match(CNT, count)]
    c(row(RULE[[r]], f0(x$value_intl_million)), row("", se0(x$value_se_intl_million)))
  })),
  "\\addlinespace",
  panel("Panel C. Value per DST season, 2017 rule (millions of 2025 international dollars)", 4),
  c(row(RULE[[1]], f0(vs$value_intl_million)), row("", se0(vs$value_se_intl_million))),
  close_))

# ── Table: the clock changes before abolition ───────────────────────────────
tr <- rd("transitions.rds")$results
tr_rows <- function(d) {
  x <- tr[design == d][match(TRAFFIC, outcome)]
  c(row("Abolition, five summers", f1(x$regime_lp)), row("", se1(x$regime_se)),
    row("End of DST in February, three weeks", f1(x$end_lp)), row("", se1(x$end_se)),
    row("Start of DST in October, three weeks", f1(x$start_lp)), row("", se1(x$start_se)),
    row("Average of the two, (February $-$ October)/2", f1(x$avg_dark_lp)), row("", se1(x$avg_dark_se)),
    row("Abolition minus the average", f1(x$diff_lp)), row("", se1(x$diff_se)),
    row("\\quad $p$-value, clustered by state", fp(x$diff_p)),
    "\\addlinespace",
    row("Abolition, school weeks of the summer window", f1(x$school_regime_lp)), row("", se1(x$school_regime_se)),
    row("Abolition in school weeks minus the average", f1(x$school_diff_lp)), row("", se1(x$school_diff_se)),
    row("\\quad $p$-value, clustered by state", fp(x$school_diff_p)))
}
write_tab("tab_transitions", c(
  open3,
  panel("Panel A. Hour after sunset (log points)", 4), tr_rows("hour0"),
  "\\addlinespace",
  panel("Panel B. Hour after sunset against hours of the same day (log points)", 4), tr_rows("within_day"),
  close_))
