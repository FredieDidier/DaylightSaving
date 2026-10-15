# =============================================================================
# 29_tables.R
#
# Every table of the paper, written as a LaTeX tabular from the estimates
# cached in audit/*.rds. Nothing is estimated here. Captions and notes live in
# the manuscript (latex/sections/body.tex and appendix_body.tex).
#
#   tab_descriptives    events per summer, group x window x period       (13)
#   tab_main            the hour that turned dark and the hour that turned
#                       light: estimate, three p-values, baseline        (01, 06)
#   tab_pedestrians     pedestrians against other road users            (12, 14)
#   tab_excess          excess events per summer, evening, morning, day  (11)
#   tab_traffic_volume  vehicles, crashes and crashes per vehicle        (15, 16)
#   tab_within_group    hour 0 against hours of the same state-day, treated
#                       and control states each alone                     (09, 15)
#   tab_robustness      the hour that turned dark under other choices,
#                       and the hours whose light did not change         (04, 05, 08, 09, 18)
#   tab_sensitivity     the hour after sunset under other clocks, samples
#                       and a rain control                               (19, 20, 23)
#   tab_road_users      who dies: road user, pedestrian age and sex, day (21)
#   tab_light_dose      darkness as a dose; rain                          (23)
#   tab_street_lighting darker against better-lit municipalities          (24)
#   tab_cost            deaths per summer and their value                 (25)
#   tab_mexico          Mexico, abolition of 2022: evening, hour before, morning,
#                       and the within-day comparison in treated units  (26, 27)
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
    row("p-value, permutation of treated states", fp(x$perm_p)),
    row("Linear model: effect (percent of baseline)", f1(x$linear_effect_pct_of_base)),
    row("Linear model: p-value, wild cluster bootstrap", fp(x$wcr_p)),
    row("Events per summer, treated states before abolition", f0(x$n_treated_win_pre / N_PRE)),
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
    row("p-value, clustered by state", fp(x$cluster_p)),
    row("p-value, wild cluster bootstrap", fp(x$wcr_p)),
    row("p-value, permutation of treated states", fp(x$perm_p)),
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
  row("p-value, permutation of treated states", fp(dx$perm_p)),
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
        # Only five of the seven hours of 11_reallocation.R appear above (the
        # hour before and the second hour after sunrise are summed, not
        # shown). The seven hours are listed in the table note
        # (latex/sections/body.tex).
        "net: all seven hours"             = "Seven hours around sunset and sunrise",
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
iv <- rd("inference_volume.rds")
pb <- function(p) sprintf("[%s]", fp(p))
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
              se1(de$crash_se), se1(de$per_vehicle_se))),
    with(iv[bin_key == b],
         row("", c(pb(vehicles_perm_p), pb(injury_perm_p), pb(injury_per_vehicle_perm_p),
                   pb(deaths_perm_p), pb(deaths_per_vehicle_perm_p)))))
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

# ── Table: sensitivity of the hour after sunset ─────────────────────────────
hp <- rd("heaping.rds")$results
lo <- rd("leave_out.rds")
ld <- rd("light_dose.rds")
sens_row <- function(label, x) c(row(label, f1(x$lp)), row("", se1(x$se)))
pick_h <- function(v) hp[variant == v & shift_min == 0L][match(TRAFFIC, outcome)]
pick_l <- function(k, d) lo[kind == k & dropped == d][match(TRAFFIC, outcome)]
rc <- ld$rain[match(TRAFFIC, outcome)]
write_tab("tab_sensitivity", c(
  open3,
  sens_row("Baseline", pick_h("shift")),
  "\\addlinespace",
  panel("Panel A. Clock time and sun", 4),
  sens_row("Sunset from the full NOAA solar calculator", pick_h("Meeus solar algorithm")),
  sens_row("Without times recorded at :00 or :30", pick_h("drop :00 and :30")),
  "\\addlinespace",
  panel("Panel B. Comparison states and seasons", 4),
  sens_row("Control states: Northeast only", pick_l("control", "North (control = Northeast only)")),
  sens_row("Control states: North only", pick_l("control", "Northeast (control = North only)")),
  sens_row("Without the La Ni\\~na summers, 2020/21 to 2022/23", pick_l("seasons", "La Nina summers 2020/21-2022/23")),
  sens_row("Without 2019/20, the first summer without DST", pick_l("seasons", "2019/20")),
  "\\addlinespace",
  panel("Panel C. Weather", 4),
  c(row("Controlling for the share of the state under rain", f1(rc$with_rain_control_lp)),
    row("", se1(rc$with_rain_control_se))),
  close_))

# ── Table: who dies (road deaths only) ──────────────────────────────────────
ru <- rd("road_users.rds")$results
RU <- list(
  list("Panel A. Road user", "road user",
       c(pedestrian = "Pedestrians", motorcyclist = "Motorcyclists",
         `car or light vehicle` = "Car and light-vehicle occupants", other = "Other road users",
         cyclist = "Cyclists")),
  list("Panel B. Pedestrians by age and sex", c("pedestrian age", "pedestrian sex"),
       c(`15-64` = "Aged 15 to 64", `65+` = "Aged 65 or over", `0-14` = "Aged under 15",
         male = "Men", female = "Women")),
  list("Panel C. Day", c("day", "day, pedestrians"),
       c(`working day` = "Working days", `weekend or holiday` = "Weekends and holidays")))
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
  " & Effect & Standard & & Deaths per summer, \\\\",
  " & (log points) & error & p-value & treated states before \\\\",
  "\\midrule",
  row("All road deaths", c(f1(allr$lp), sprintf("(%s)", formatC(allr$se, format = "f", digits = 1)),
                           fp(allr$p), f1(allr$pre_per_season))),
  "\\addlinespace", panel(RU[[1]][[1]], 5), ru_rows(RU[[1]][[2]], RU[[1]][[3]]),
  "\\addlinespace", panel(RU[[2]][[1]], 5), ru_rows(RU[[2]][[2]], RU[[2]][[3]]),
  "\\addlinespace", panel(RU[[3]][[1]], 5), ru_rows("day", RU[[3]][[3]]),
  ru_rows("day, pedestrians", setNames(paste("Pedestrians,", tolower(RU[[3]][[3]])), names(RU[[3]][[3]]))),
  close_))

# ── Table: darkness as a dose, and rain ─────────────────────────────────────
fs <- ld$first_stage; wd_ <- ld$wald[match(TRAFFIC, outcome)]
write_tab("tab_light_dose", c(
  open3,
  panel("Panel A. Darkness as a dose", 4),
  row("Crashes recorded dark (percentage points)",
      c("", "", sprintf("%s (%s)", f1(fs$fs_pp), formatC(fs$fs_se_pp, format = "f", digits = 1)))),
  row("Effect of a fully dark hour (log points)", f1(wd_$wald_lp_per_full_dark)),
  row("", ci1(wd_$lo, wd_$hi)),
  "\\addlinespace",
  panel("Panel B. Rain (log points)", 4),
  row("Effect on a dry state-day", f1(rc$effect_dry_lp)),
  row("", se1(rc$effect_dry_se)),
  row("Change, dry to fully rainy state-day", f1(rc$rain_change_lp)),
  row("", se1(rc$rain_change_se)),
  close_))

# ── Table: street lighting ──────────────────────────────────────────────────
sl <- rd("street_lighting.rds")$results
SLO <- c("SIM transport deaths, on road", "SIM pedestrian deaths, on road", "PRF injury accidents")
sl_rows <- function(b, meas = "unlit_pct_2022") {
  x <- sl[bin == b & measure == meas][match(SLO, outcome)]
  c(row("Municipalities with darker streets", f1(x$dark_lp)), row("", se1(x$dark_se)),
    row("Municipalities with better-lit streets", f1(x$lit_lp)), row("", se1(x$lit_se)),
    row("Difference, p-value", fp(x$diff_p)))
}
write_tab("tab_street_lighting", c(
  "\\begin{tabular}{@{}l ccc@{}}", "\\toprule",
  " & Road & Pedestrian & Federal highway \\\\",
  " & deaths & road deaths & injury crashes \\\\",
  " & (1) & (2) & (3) \\\\",
  "\\midrule",
  panel("Panel A. Hour after sunset, Census 2022 (log points)", 4), sl_rows(0L),
  "\\addlinespace",
  panel("Panel B. Hour before sunset, light unchanged, Census 2022 (log points)", 4), sl_rows(-1L),
  "\\addlinespace",
  panel("Panel C. Hour after sunset, Census 2010 (log points)", 4), sl_rows(0L, "unlit_pct_2010"),
  close_))

# ── Table: deaths and their value per summer ────────────────────────────────
tc <- rd("total_cost.rds")
dn <- tc$deaths[sum == "net: evening 0, +1 and morning 0"]
vl <- tc$value[sum == "net: evening 0, +1 and morning 0"]
CNT <- c("A on road, with clock time", "B on road", "C all transport deaths")
RULE <- c("(a) elasticity 1.5 from the US ratio of 160" = "VSL, income elasticity 1.5 (reference)",
          "(c) 100 x GNI per capita" = "VSL, 100 $\\times$ income per head",
          "(b) 160 x GNI per capita" = "VSL, 160 $\\times$ income per head",
          "(d) IPEA social cost of a death (human capital)" = "Ipea social cost of a death")
write_tab("tab_cost", c(
  "\\begin{tabular}{@{}l ccc@{}}", "\\toprule",
  " & Road deaths with & All road & All transport \\\\",
  " & a clock time & deaths & deaths \\\\",
  " & (1) & (2) & (3) \\\\",
  "\\midrule",
  panel("Panel A. Excess deaths per summer", 4),
  row("Two hours after sunset and hour after sunrise", f0(dn[match(CNT, count)]$deaths)),
  row("", se0(dn[match(CNT, count)]$se)),
  row("Share of summer transport deaths (percent)",
      f1(dn[match(CNT, count)]$share_of_summer_transport_deaths_pct)),
  "\\addlinespace",
  panel("Panel B. Value per summer (millions of 2025 reais)", 4),
  unlist(lapply(names(RULE), function(r) {
    x <- vl[rule == r][match(CNT, count)]
    c(row(RULE[[r]], f0(x$value_brl_million)), row("", se0(x$value_se_brl_million)))
  })),
  close_))

# ── Table: Mexico, the 2022 abolition ───────────────────────────────────────
mx <- rd("mexico.rds")
MXO <- c("Deaths", "Pedestrian deaths", "Accidents with victims", "Pedestrians struck, with victims")
mx_rows <- function(s, b, inference = FALSE) {
  x <- mx$by_hour[side == s & bin == b][match(MXO, outcome)]
  out <- c(row("Effect of abolition (log points)", f1(x$lp)), row("", se1(x$se)),
           row("p-value, clustered by unit", fp(x$p)))
  if (inference) {
    i <- mx$inference[match(MXO, outcome)]
    out <- c(out, row("p-value, wild cluster bootstrap", fp(i$wcr_p)),
             row("p-value, permutation of treated units", fp(i$perm_p)))
  }
  c(out, row("Events per year, treated units, before", f1(x$pre_per_year)))
}
write_tab("tab_mexico", c(
  "\\begin{tabular}{@{}l cccc@{}}", "\\toprule",
  " & & Pedestrian & Accidents & Pedestrians struck, \\\\",
  " & Deaths & deaths & with victims & with victims \\\\",
  " & (1) & (2) & (3) & (4) \\\\",
  "\\midrule",
  panel("Panel A. Hour after sunset, which turned dark", 5), mx_rows("set", 0L, TRUE),
  "\\addlinespace",
  panel("Panel B. Hour before sunset, light unchanged", 5), mx_rows("set", -1L),
  "\\addlinespace",
  panel("Panel C. Hour after sunrise, which turned light", 5), mx_rows("rise", 0L),
  "\\addlinespace",
  panel("Panel D. Treated units only: hour after sunset against hours of the same day", 5),
  {
    w <- rd("mexico_within_day.rds")[bin == 0L][match(MXO, outcome)]
    c(row("Effect of abolition (log points)", f1(w$lp)), row("", se1(w$se)),
      row("p-value, clustered by unit", fp(w$p)))
  },
  close_))
