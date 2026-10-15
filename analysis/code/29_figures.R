# =============================================================================
# 29_figures.R
#
# Every figure of the paper, drawn from the estimates cached in audit/*.rds
# (and, for the two maps, from the boundaries of build/12_map_boundaries.R).
# Nothing is estimated here, so a label, a colour or a size changes in seconds
# and never requires a refit. Run after 01-28, which write the caches.
#
# Main text
#   fig_map_brazil        treated, control and excluded states   (maps/, no cache)
#   fig_light             A: clock time of sunset and sunrise, Sao Paulo
#                         2018/19, with and without DST (no cache); B: share of
#                         PRF crashes recorded dark, by minute from standard
#                         sunset, summer window                    (03)
#   fig_hours_from_sunset effect by clock hour relative to standard sunset and
#                         sunrise                                  (01)
#   fig_event_study       hour after sunset vs hour before, by season (02)
# Appendix
#   fig_within_day        event study with state-by-day fixed effects (09, 02)
#   fig_window_legs       treated - control by season, summer and off-season (04)
#   fig_honestdid         Rambachan-Roth sensitivity               (07)
#   fig_assault           assault deaths, whole day and 5-8 p.m.   (10)
#   fig_bahia             Bahia's single DST season, 2011/12       (17)
#   fig_window_shift      the hour moved earlier and later         (19)
#   fig_leave_out         one state or one season left out         (20)
#   fig_record_integrity  share on the road, share without a time  (22)
#   fig_mexico_event_study Mexico, hour after sunset by year       (26)
#   fig_map_mexico        units that lost DST, kept their clock, or left out
#                                                                  (maps/, no cache)
#
# House style (00_utils.R): no titles inside the figure (the caption lives in
# LaTeX); outcome names as in OUTCOME_LAB, never with the data source; one y
# axis per panel, on the left; legend at the bottom with no title.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

rd <- function(f) readRDS(file.path(path_audit, f))
TRAFFIC_LAB <- unname(OUTCOME_LAB[TRAFFIC])
ci <- function(b, s) list(lo = 100 * (b - 1.96 * s), hi = 100 * (b + 1.96 * s))

# Season event studies share one frame: seasons on x, the post-abolition
# seasons shaded and labelled once, a zero line, 95% intervals.
event_frame <- function(seasons, first_panel = NULL, facet = TRUE) {
  lab <- data.frame(x = (LAST_PRE + 0.5 + max(seasons) + 0.5) / 2, y = Inf, label = POST_LABEL)
  if (!is.null(first_panel)) lab$outcome <- factor(first_panel[1], levels = first_panel)
  list(
    annotate("rect", xmin = LAST_PRE + 0.5, xmax = max(seasons) + 0.5, ymin = -Inf, ymax = Inf,
             fill = "grey94"),
    geom_text(data = lab, aes(x, y, label = label), inherit.aes = FALSE, vjust = 1.6,
              size = 3, colour = "grey35"),
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4),
    scale_x_continuous(breaks = seq(min(seasons), max(seasons), 2), labels = season_lab,
                       expand = expansion(add = 0.4)),
    scale_y_continuous(labels = num_lab, expand = expansion(mult = c(0.05, 0.12)))
  )
}
dodge <- position_dodge(width = 0.5)

# ── Design: Sao Paulo, 2018/19 ──────────────────────────────────────────────
# DST in 2018/19 ran 4 Nov 2018 to 17 Feb 2019 (Decree 9,242/2017 rule). The
# DST line is drawn only while DST was in force (plus the day on each side, so
# the jumps show); elsewhere the two clocks coincide and one line is enough.
d <- data.table(date = seq(as.Date("2018-07-01"), as.Date("2019-06-30"), by = "day"))
st <- sun_times(d$date, -23.55, -46.63, -3)
d[, `:=`(sunset = st$sunset / 60, sunrise = st$sunrise / 60)]
d[, dst := as.integer(date >= as.Date("2018-11-04") & date < as.Date("2019-02-17"))]
d[, near := dst == 1L | shift(dst, -1L, fill = 0L) == 1L | shift(dst, 1L, fill = 0L) == 1L]
REG <- c("With DST (until 2018/19)", "Without DST (from 2019/20)")
EVT <- c("Sunset", "Sunrise")
long <- rbind(
  d[near == TRUE, .(date, h = sunset + dst,  event = "Sunset",  regime = REG[1])],
  d[,             .(date, h = sunset,        event = "Sunset",  regime = REG[2])],
  d[near == TRUE, .(date, h = sunrise + dst, event = "Sunrise", regime = REG[1])],
  d[,             .(date, h = sunrise,       event = "Sunrise", regime = REG[2])])
long[, `:=`(event = factor(event, levels = EVT), regime = factor(regime, levels = REG))]
WIN <- as.Date(c("2018-11-15", "2019-02-14"))
band <- rbind(d[date %between% WIN, .(date, lo = sunset,  hi = sunset + 1,  event = "Sunset")],
              d[date %between% WIN, .(date, lo = sunrise, hi = sunrise + 1, event = "Sunrise")])
band[, `:=`(event = factor(event, levels = EVT), what = "Hour whose light changed")]
win_lab <- data.frame(x = mean(WIN), y = Inf, label = "Summer window",
                      event = factor("Sunset", levels = EVT))
hfmt <- function(x) sprintf("%d:%02d", floor(x), round(60 * (x - floor(x))))
g <- ggplot(long, aes(date, h)) +
  annotate("rect", xmin = WIN[1], xmax = WIN[2], ymin = -Inf, ymax = Inf, fill = "grey94") +
  geom_text(data = win_lab, aes(x, y, label = label), inherit.aes = FALSE, vjust = 1.6,
            size = 3, colour = "grey35") +
  geom_ribbon(data = band, aes(x = date, ymin = lo, ymax = hi, fill = what), inherit.aes = FALSE,
              alpha = 0.3) +
  geom_line(aes(colour = regime, linetype = regime), linewidth = 0.7) +
  facet_wrap(~ event, ncol = 2, scales = "free_y") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b", expand = expansion(add = 4)) +
  scale_y_continuous(labels = hfmt, expand = expansion(mult = c(0.04, 0.14))) +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["blue"]]), REG)) +
  scale_linetype_manual(values = setNames(c("solid", "22"), REG)) +
  scale_fill_manual(values = c("Hour whose light changed" = PAL[["red"]])) +
  labs(x = NULL, y = "Clock time") +
  theme_paper() + theme(legend.box = "vertical", legend.spacing.y = unit(2, "pt")) +
  guides(colour = guide_legend(order = 1), linetype = guide_legend(order = 1),
         fill = guide_legend(order = 2))
g_design <- g

# ── First stage: what the police officer saw ────────────────────────────────
# Share of PRF crashes in treated states, summer window, recorded at dusk or
# night, by 10-minute bin of clock time minus standard-time sunset (plotted at
# the bin midpoint).
fs <- rd("prf_clock_check.rds")$window_curve
FS <- c("With DST, 2009/10\u20132018/19", "Without DST, 2019/20\u20132024/25")
fs <- rbind(fs[, .(m = rbin + 5, share = 100 * `pre (DST)`,     regime = FS[1])],
            fs[, .(m = rbin + 5, share = 100 * `post (no DST)`, regime = FS[2])])
fs[, regime := factor(regime, levels = FS)]
g <- ggplot(fs, aes(m, share)) +
  annotate("rect", xmin = 0, xmax = 60, ymin = -Inf, ymax = Inf, fill = PAL[["red"]], alpha = 0.12) +
  annotate("text", x = 30, y = 18, label = "Hour whose\nlight changed", size = 3,
           colour = "grey30", lineheight = 0.9) +
  geom_line(aes(colour = regime, linetype = regime), linewidth = 0.6) +
  geom_point(aes(colour = regime, shape = regime), size = 1.5) +
  scale_x_continuous(breaks = seq(-120, 180, 60), labels = signed_lab) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["blue"]]), FS)) +
  scale_linetype_manual(values = setNames(c("solid", "22"), FS)) +
  scale_shape_manual(values = setNames(c(16, 17), FS)) +
  labs(x = "Clock minutes from standard-time sunset",
       y = "Recorded at dusk or night (%)") +
  theme_paper()
g_first <- g

# ── The hour whose light changed: clock and first stage, one figure ────────
# Panel A is the clock in Sao Paulo; Panel B what the police recorded in
# that hour. Panel titles sit above each panel, flush left, as in stack_rows().
ptitle <- function(g, txt) g + labs(title = txt) +
  theme(plot.title = element_text(size = 10, face = "bold", hjust = 0, margin = margin(2, 0, 10, 0)),
        plot.title.position = "plot")
g <- patchwork::wrap_plots(
  ptitle(g_design, "A. Clock time of sunset and sunrise, S\u00e3o Paulo, 2018/19"),
  ptitle(g_first, "B. Federal highway crashes recorded at dusk or night, treated states, summer window"),
  ncol = 1, heights = c(1, 1))
save_fig(g, "fig_light", height = 7)

# ── Effect by hour from sunset and sunrise ──────────────────────────────────
SIDE <- c("Evening: hours from sunset", "Morning: hours from sunrise")
HR   <- c("Hour whose light changed", "Other hours")
sd_ <- rd("sunset_design.rds")$results[outcome %in% TRAFFIC]
sd_[, `:=`(side = factor(fifelse(grepl("^evening", side), SIDE[1], SIDE[2]), levels = SIDE),
           hour = factor(fifelse(bin == 0L, HR[1], HR[2]), levels = HR))]
sd_[, c("lo", "hi") := ci(coef, se)]
rows <- lapply(TRAFFIC, function(o)
  ggplot(sd_[outcome == o], aes(bin, 100 * coef, colour = hour, shape = hour)) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.6) +
    geom_point(size = 2) +
    facet_wrap(~ side, nrow = 1) +
    scale_x_continuous(breaks = -3:2, labels = signed_lab, limits = c(-3.4, 2.4)) +
    scale_y_continuous(labels = num_lab) +
    scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["grey"]]), HR), drop = FALSE) +
    scale_shape_manual(values = setNames(c(16, 1), HR), drop = FALSE) +
    labs(title = OUTCOME_LAB[[o]], x = "Clock hour relative to standard-time sunset or sunrise",
         y = "Effect of abolition (log points)") +
    theme_paper())
save_fig(stack_rows(rows), "fig_hours_from_sunset", height = 6.4)

# ── Event study: the hour after sunset and the hour before ──────────────────
# Coefficients against the average of the seasons before abolition (02), the
# comparison the pooled estimate makes.
HB <- c("Hour after sunset (turned dark)", "Hour before sunset (sun lower, not set)")
es <- rd("switched_hour_event_study.rds")$event_study
es[, `:=`(outcome = factor(OUTCOME_LAB[outcome], levels = TRAFFIC_LAB),
          hour = factor(fifelse(bin == 0L, HB[1], HB[2]), levels = HB))]
es[, c("lo", "hi") := ci(coef_vs_pre, se_vs_pre)]
g <- ggplot(es, aes(sy, 100 * coef_vs_pre, colour = hour, shape = hour)) +
  event_frame(es$sy, TRAFFIC_LAB) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.5, position = dodge) +
  geom_point(size = 1.8, position = dodge) +
  facet_wrap(~ outcome, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["grey"]]), HB)) +
  scale_shape_manual(values = setNames(c(16, 1), HB)) +
  labs(x = "Season", y = "Relative to the average season with DST (log points)") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_event_study", height = 7)

# ── Appendix: within the day ────────────────────────────────────────────────
WD <- c("Triple difference", "With state-by-day fixed effects")
wd <- rbind(rd("switched_hour_event_study.rds")$event_study[bin == 0L, .(outcome, sy, coef = coef_vs_pre,
                                                                          se = se_vs_pre, design = WD[1])],
            rd("within_day.rds")$event_study[, .(outcome, sy, coef = coef_vs_pre, se = se_vs_pre,
                                                 design = WD[2])])
wd[, `:=`(outcome = factor(OUTCOME_LAB[outcome], levels = TRAFFIC_LAB),
          design = factor(design, levels = WD))]
wd[, c("lo", "hi") := ci(coef, se)]
g <- ggplot(wd, aes(sy, 100 * coef, colour = design, shape = design)) +
  event_frame(wd$sy, TRAFFIC_LAB) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.5, position = dodge) +
  geom_point(size = 1.8, position = dodge) +
  facet_wrap(~ outcome, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = setNames(c(PAL[["grey"]], PAL[["red"]]), WD)) +
  scale_shape_manual(values = setNames(c(1, 16), WD)) +
  labs(x = "Season", y = "Hour after sunset, relative to the average season with DST (log points)") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_within_day", height = 7)

# ── Appendix: the two legs of the triple difference ─────────────────────────
# Treated minus control states in the hour after sunset, season by season,
# in the summer window and in the off-season separately (04); the triple
# difference is the first minus the second.
LG <- c("Summer window", "Off-season")
lg <- rd("pretrends.rds")$legs
lg[, `:=`(outcome = factor(OUTCOME_LAB[outcome], levels = TRAFFIC_LAB),
          leg = factor(fifelse(window == "win", LG[1], LG[2]), levels = LG))]
lg[, c("lo", "hi") := ci(coef, se)]
g <- ggplot(lg, aes(sy, 100 * coef, colour = leg, shape = leg)) +
  event_frame(lg$sy, TRAFFIC_LAB) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.5, position = dodge) +
  geom_point(size = 1.8, position = dodge) +
  facet_wrap(~ outcome, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["blue"]]), LG)) +
  scale_shape_manual(values = setNames(c(16, 17), LG)) +
  labs(x = "Season", y = "Treated minus control, relative to 2018/19 (log points)") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_window_legs", height = 7)

# ── Appendix: HonestDiD ─────────────────────────────────────────────────────
# Columns are the two restrictions (plotmath strips, so M-bar has its bar);
# x is how far the post-period violation may exceed the pre-period one, with
# the original interval first.
RESTR <- c("smoothness (M)"            = "Smoothness~restriction~(italic(M))",
           "relative magnitude (Mbar)" = "Relative~magnitudes~(italic(bar(M)))")
KIND <- c("Original confidence interval", "Robust confidence interval")
hd <- rd("honestdid.rds")
hd_fig <- rbind(
  hd[restriction == "original"][rep(seq_len(.N), each = 2)][
    , `:=`(restriction = rep(names(RESTR), .N / 2), x = "Original", kind = KIND[1])],
  hd[restriction != "original"][, `:=`(x = format(param, drop0trailing = TRUE, trim = TRUE),
                                       kind = KIND[2])])
hd_fig[, `:=`(restriction = factor(RESTR[restriction], levels = RESTR),
              kind = factor(kind, levels = KIND))]
hd_fig[, x := factor(x, levels = unique(c("Original", format(sort(unique(hd$param)),
                                                             drop0trailing = TRUE, trim = TRUE))))]
rows <- lapply(TRAFFIC, function(o)
  ggplot(hd_fig[outcome == o], aes(x, ymin = 100 * lb, ymax = 100 * ub, colour = kind)) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
    geom_linerange(linewidth = 1.6) +
    facet_wrap(~ restriction, nrow = 1, scales = "free", labeller = label_parsed) +
    scale_y_continuous(labels = num_lab) +
    scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["blue"]]), KIND)) +
    labs(title = OUTCOME_LAB[[o]], x = "Allowed violation of parallel trends",
         y = "Average effect after abolition (log points)") +
    theme_paper() + theme(axis.text.x = element_text(size = 8)))
save_fig(stack_rows(rows), "fig_honestdid", height = 6.6)

# ── Appendix: assault deaths ────────────────────────────────────────────────
BL <- c("Whole day", "5\u20138 p.m.")
as_ <- rd("assault_trends.rds")$event_study[block %in% c("all day", "17-20h")]
as_[, block := factor(fifelse(block == "all day", BL[1], BL[2]), levels = BL)]
as_[, c("lo", "hi") := ci(coef, se)]
g <- ggplot(as_, aes(sy, 100 * coef, colour = block, shape = block)) +
  event_frame(as_$sy) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.5, position = dodge) +
  geom_point(size = 1.8, position = dodge) +
  scale_colour_manual(values = setNames(c(PAL[["ink"]], PAL[["blue"]]), BL)) +
  scale_shape_manual(values = setNames(c(15, 16), BL)) +
  labs(x = "Season", y = "Relative to 2018/19 (log points)") +
  theme_paper()
save_fig(g, "fig_assault", height = 3.4)

# ── Appendix: Bahia, 2011/12 ────────────────────────────────────────────────
BA_SEASON <- 2011L
BS <- c("Hour after sunset", "Hour after sunrise")
BP <- c("2011/12, Bahia on DST", "Other seasons")
ba <- rd("bahia_switch.rds")$by_season[outcome %in% TRAFFIC]
ba[, `:=`(side = factor(fifelse(side == "set", BS[1], BS[2]), levels = BS),
          season = factor(fifelse(sy == BA_SEASON, BP[1], BP[2]), levels = BP))]
rows <- lapply(TRAFFIC, function(o)
  ggplot(ba[outcome == o], aes(sy, 100 * coef, colour = season, shape = season)) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
    geom_point(size = 2) +
    facet_wrap(~ side, nrow = 1) +
    scale_x_continuous(breaks = c(2011L, 2015L, 2019L, 2023L), labels = season_lab,
                       expand = expansion(add = 0.8)) +
    scale_y_continuous(labels = num_lab) +
    scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["grey"]]), BP)) +
    scale_shape_manual(values = setNames(c(16, 1), BP)) +
    labs(title = OUTCOME_LAB[[o]], x = "Season",
         y = "That season against the other Bahia seasons (log points)") +
    theme_paper())
save_fig(stack_rows(rows), "fig_bahia", height = 6.2)

# ── Appendix: the hour moved earlier and later ──────────────────────────────
# Each point: the 60-minute window starting s minutes after standard-time
# sunset (19_heaping.R). s = 0 is the paper's hour.
sh <- rd("heaping.rds")$results[variant == "shift"]
sh[, `:=`(outcome = factor(OUTCOME_LAB[outcome], levels = TRAFFIC_LAB),
          base = factor(fifelse(shift_min == 0L, "The paper's hour", "Window moved"),
                        levels = c("The paper's hour", "Window moved")))]
sh[, c("lo", "hi") := ci(lp / 100, se / 100)]
g <- ggplot(sh, aes(shift_min, lp, colour = base, shape = base)) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.6) +
  geom_point(size = 2) +
  facet_wrap(~ outcome, ncol = 1, scales = "free_y") +
  scale_x_continuous(breaks = seq(-15, 15, 5), labels = signed_lab) +
  scale_y_continuous(labels = num_lab) +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["grey"]]), levels(sh$base))) +
  scale_shape_manual(values = setNames(c(16, 1), levels(sh$base))) +
  labs(x = "Start of the 60-minute window, minutes after standard-time sunset",
       y = "Effect of abolition (log points)") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_window_shift", height = 6.4)

# ── Appendix: leave one state or one season out ─────────────────────────────
lo_ <- rd("leave_out.rds")
base_ <- lo_[kind == "baseline", .(outcome, base_lp = lp)]
lv <- lo_[kind %in% c("state", "season")][base_, on = "outcome"]
LV <- c(state = "One state left out", season = "One season left out")
lv[, `:=`(outcome = factor(OUTCOME_LAB[outcome], levels = TRAFFIC_LAB),
          kind = factor(LV[kind], levels = LV))]
lv[, c("lo", "hi") := ci(lp / 100, se / 100)]
lv[, ord := frank(lp, ties.method = "first"), by = .(outcome, kind)]
rows <- lapply(TRAFFIC_LAB, function(o)
  ggplot(lv[outcome == o], aes(ord, lp)) +
    geom_hline(aes(yintercept = base_lp), colour = PAL[["red"]], linewidth = 0.5, linetype = "22") +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.4, colour = PAL[["grey"]]) +
    geom_point(size = 1.4, colour = PAL[["ink"]]) +
    geom_text(aes(y = hi, label = dropped), angle = 90, hjust = -0.12, size = 2.8, colour = "grey20") +
    facet_wrap(~ kind, nrow = 1, scales = "free_x") +
    scale_x_continuous(breaks = NULL) +
    scale_y_continuous(labels = num_lab, expand = expansion(mult = c(0.05, 0.5))) +
    labs(title = o, x = "Estimates ordered from smallest to largest; dashed line: all states and seasons",
         y = "Effect of abolition (log points)") +
    theme_paper())
save_fig(stack_rows(rows), "fig_leave_out", height = 8.2)

# ── Appendix: how deaths are recorded ───────────────────────────────────────
ri_ <- rd("record_integrity.rds")$series[window == "win"]
MS <- c(on_road = "Transport deaths that occurred on the road",
        no_time = "On-road deaths without a clock time")
GR <- c(treated = "States with DST until 2018/19", control = "Control states")
ri_[, `:=`(measure = factor(MS[measure], levels = MS), group = factor(GR[group], levels = GR))]
g <- ggplot(ri_, aes(sy, share, colour = group, shape = group, linetype = group)) +
  event_frame(ri_$sy) +
  geom_line(linewidth = 0.6) + geom_point(size = 1.6) +
  facet_wrap(~ measure, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["blue"]]), GR)) +
  scale_shape_manual(values = setNames(c(16, 17), GR)) +
  scale_linetype_manual(values = setNames(c("solid", "22"), GR)) +
  labs(x = "Season", y = "Percent, summer window") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_record_integrity", height = 5.2)

# ── Mexico: the hour after sunset, year by year ─────────────────────────────
MXO <- c("Deaths", "Pedestrian deaths", "Accidents with victims", "Pedestrians struck, with victims")
mxe <- rd("mexico.rds")$event_study[outcome %in% MXO]
mxe[, outcome := factor(outcome, levels = MXO)]
mxe[, c("lo", "hi") := ci(coef, se)]
mxlab <- data.frame(x = (2022.5 + 2025.5) / 2, y = Inf, label = POST_LABEL,
                    outcome = factor(MXO[1], levels = MXO))
g <- ggplot(mxe, aes(sy, 100 * coef)) +
  annotate("rect", xmin = 2022.5, xmax = 2025.5, ymin = -Inf, ymax = Inf, fill = "grey94") +
  geom_text(data = mxlab, aes(x, y, label = label), inherit.aes = FALSE, vjust = 1.6,
            size = 3, colour = "grey35") +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.5, colour = PAL[["red"]]) +
  geom_point(size = 1.8, colour = PAL[["red"]]) +
  facet_wrap(~ outcome, ncol = 2, scales = "free_y") +
  scale_x_continuous(breaks = seq(2016, 2025, 2), expand = expansion(add = 0.4)) +
  scale_y_continuous(labels = num_lab, expand = expansion(mult = c(0.05, 0.15))) +
  labs(x = "Year", y = "Relative to 2022 (log points)") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_mexico_event_study", height = 5.4)

# ── Maps (analysis/output/maps) ─────────────────────────────────────────────
# Boundaries from build/12_map_boundaries.R (IBGE 2020 for Brazil, GADM 4.1
# for Mexico); neighbouring countries from Natural Earth (medium scale) as grey
# context. Three fills only (treated, comparison, excluded): a choropleth puts
# every pair of colours side by side, and red and blue are the pair the palette
# check passes; the excluded units are told apart by their labels and the
# legend, not by a fourth colour.
suppressPackageStartupMessages(library(sf))
dir.create(path_maps, recursive = TRUE, showWarnings = FALSE)
MAP_FILL <- c(PAL[["red"]], PAL[["blue"]], "#D5D8DC")
map_theme <- function() theme_void(base_size = 10) +
  theme(legend.position = "bottom", legend.direction = "vertical", legend.title = element_blank(),
        legend.text = element_text(size = 9), legend.key.size = unit(0.45, "cm"),
        legend.margin = margin(t = 0), plot.margin = margin(2, 2, 2, 2))
# Natural Earth polygons are cropped in longitude-latitude before projection:
# a whole-world layer leaves slivers across the ocean once projected.
sf_use_s2(FALSE)
world <- suppressMessages(suppressWarnings(
  rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")[, "admin"]))
context <- function(xmin, xmax, ymin, ymax, crs)
  st_transform(suppressMessages(suppressWarnings(
    st_crop(world, c(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)))), crs)

# Brazil: treatment groups of 00_utils.R, Equator and Tropic of Capricorn.
BR_GRP <- c("Treated: DST every summer from 2008/09 to 2018/19",
            "Control: no DST",
            "Excluded: DST in one summer only (BA 2011/12, TO 2012/13) or a time-zone change (AC, AM)")
br <- st_transform(st_read(file.path(DROPBOX_ROOT, "build", "geo", "output", "br_states.gpkg"),
                           quiet = TRUE), 5880)
br$grp <- factor(ifelse(br$abbrev_state %in% TREATED, BR_GRP[1],
                        ifelse(br$abbrev_state %in% CONTROL, BR_GRP[2], BR_GRP[3])), levels = BR_GRP)
stopifnot(sum(br$grp == BR_GRP[1]) == 11L, sum(br$grp == BR_GRP[2]) == 12L)
lab <- suppressWarnings(st_point_on_surface(br))
lab <- cbind(as.data.frame(st_coordinates(lab)), uf = br$abbrev_state, grp = br$grp)
lab$ink <- ifelse(lab$grp == BR_GRP[3], "grey20", "white")
# Units too small to hold their label: the label goes off the unit, in the
# sea or on a grey (excluded) neighbour, with a leader line (lon, lat).
OFF <- list(DF = c(-45.6, -12.9), RN = c(-34.2, -4.9), PB = c(-33.4, -6.9), AL = c(-34.2, -10.2),
            SE = c(-35.6, -11.9), ES = c(-38.4, -20.3), RJ = c(-39.8, -24.6))
off <- do.call(rbind, lapply(names(OFF), function(u)
  data.frame(uf = u, st_coordinates(st_transform(st_sfc(st_point(OFF[[u]]), crs = 4326), 5880)))))
names(off)[2:3] <- c("Xl", "Yl")
seg <- merge(lab[, c("uf", "X", "Y")], off, by = "uf")
lab <- merge(lab, off, by = "uf", all.x = TRUE)
moved <- !is.na(lab$Xl)
lab$X[moved] <- lab$Xl[moved]; lab$Y[moved] <- lab$Yl[moved]; lab$ink[moved] <- "grey15"
parallels <- st_transform(st_sfc(st_linestring(cbind(c(-76, -31), c(0, 0))),
                                 st_linestring(cbind(c(-76, -31), c(-23.44, -23.44))), crs = 4326), 5880)
par_lab <- data.frame(label = c("Equator", "Tropic of Capricorn"),
                      st_coordinates(st_transform(st_sfc(st_point(c(-31.5, 0.9)),
                                                         st_point(c(-31.5, -22.5)), crs = 4326), 5880)))
bb <- st_bbox(br)
g <- ggplot() +
  geom_sf(data = context(-90, -20, -45, 15, 5880), fill = "grey96", colour = "white", linewidth = 0.3) +
  geom_sf(data = parallels, colour = "grey55", linewidth = 0.3, linetype = "22") +
  geom_text(data = par_lab, aes(X, Y, label = label), size = 2.7, colour = "grey35", hjust = 1) +
  geom_sf(data = br, aes(fill = grp), colour = "white", linewidth = 0.35) +
  geom_segment(data = seg, aes(x = X, y = Y, xend = Xl, yend = Yl), colour = "grey35", linewidth = 0.25) +
  geom_label(data = lab[moved, ], aes(X, Y, label = uf), size = 2.6, fontface = "bold", colour = "grey15",
             fill = "white", linewidth = 0, label.padding = unit(0.06, "lines")) +
  geom_text(data = lab[!moved, ], aes(X, Y, label = uf, colour = ink), size = 2.6, fontface = "bold") +
  scale_colour_identity() +
  scale_fill_manual(values = setNames(MAP_FILL, BR_GRP), drop = FALSE) +
  coord_sf(xlim = c(bb[["xmin"]] - 1e5, bb[["xmax"]] + 3.2e5), ylim = c(bb[["ymin"]] - 1e5, bb[["ymax"]] + 1e5),
           expand = FALSE, datum = NA) +
  map_theme()
save_fig(g, "fig_map_brazil", height = 6, dir = path_maps)

# Mexico: units of 26_mexico.R. The border municipalities that kept DST on US
# dates are drawn over their states.
MX_GRP <- c("Treated: lost DST in October 2022",
            "Comparison: clock unchanged (no DST in Sonora and Quintana Roo; DST on US dates in Baja California and 22 border municipalities)",
            "Excluded: Chihuahua, which also changed time zone")
mx <- st_read(file.path(DROPBOX_ROOT, "build", "mexico", "output", "mx_states.gpkg"), quiet = TRUE)
mx$grp <- factor(ifelse(mx$cve_ent %in% MX_CONTROL_STATES, MX_GRP[2],
                        ifelse(mx$cve_ent == "08", MX_GRP[3], MX_GRP[1])), levels = MX_GRP)
mun <- st_read(file.path(DROPBOX_ROOT, "build", "mexico", "output", "mx_border_states_munis.gpkg"), quiet = TRUE)
mnorm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
bm <- do.call(rbind, lapply(names(MX_BORDER), function(e) data.frame(cve_ent = e, nm = mnorm(MX_BORDER[[e]]))))
mun <- mun[paste(mun$cve_ent, mnorm(mun$name)) %in% paste(bm$cve_ent, bm$nm), ]
stopifnot(nrow(mun) == 22L)
mun$grp <- factor(MX_GRP[2], levels = MX_GRP)
mlab <- suppressWarnings(st_point_on_surface(mx[mx$cve_ent %in% c(MX_CONTROL_STATES, "08"), ]))
mlab <- cbind(as.data.frame(st_coordinates(mlab)), cve = mlab$cve_ent,
              label = c("02" = "Baja\nCalifornia", "08" = "Chihuahua", "23" = "Quintana\nRoo",
                        "26" = "Sonora")[mlab$cve_ent])
mlab$ink <- ifelse(mlab$cve == "08", "grey20", "white")
# Baja California and Quintana Roo are too narrow for their names: the label
# goes in the sea with a leader line (lon, lat).
MOFF <- list("02" = c(-117.2, 26.4), "23" = c(-85.0, 20.4))
moff <- do.call(rbind, lapply(names(MOFF), function(e)
  data.frame(cve = e, st_coordinates(st_transform(st_sfc(st_point(MOFF[[e]]), crs = 4326), 6372)))))
names(moff)[2:3] <- c("Xl", "Yl")
mseg <- merge(mlab[, c("cve", "X", "Y")], moff, by = "cve")
mlab <- merge(mlab, moff, by = "cve", all.x = TRUE)
mmoved <- !is.na(mlab$Xl)
mlab$X[mmoved] <- mlab$Xl[mmoved]; mlab$Y[mmoved] <- mlab$Yl[mmoved]
mbb <- st_bbox(mx)
g <- ggplot() +
  geom_sf(data = context(-140, -65, 0, 52, 6372), fill = "grey96", colour = "white", linewidth = 0.3) +
  geom_sf(data = mx, aes(fill = grp), colour = "white", linewidth = 0.35) +
  geom_sf(data = mun, aes(fill = grp), colour = "white", linewidth = 0.15) +
  geom_segment(data = mseg, aes(x = X, y = Y, xend = Xl, yend = Yl), colour = "grey35", linewidth = 0.25) +
  geom_label(data = mlab[mmoved, ], aes(X, Y, label = label), size = 2.6, fontface = "bold",
             colour = "grey15", lineheight = 0.9, fill = "white", linewidth = 0,
             label.padding = unit(0.08, "lines")) +
  geom_text(data = mlab[!mmoved, ], aes(X, Y, label = label, colour = ink), size = 2.6, fontface = "bold") +
  scale_colour_identity() +
  scale_fill_manual(values = setNames(MAP_FILL, MX_GRP), drop = FALSE,
                    labels = function(x) gsub("; ", ";\n", x)) +
  coord_sf(xlim = c(mbb[["xmin"]] - 3.5e5, mbb[["xmax"]] + 3.5e5), ylim = c(mbb[["ymin"]] - 1e5, mbb[["ymax"]] + 5e4),
           expand = FALSE, datum = NA) +
  map_theme()
save_fig(g, "fig_map_mexico", height = 4.9, dir = path_maps)
