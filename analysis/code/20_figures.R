# =============================================================================
# 20_figures.R
#
# Every figure of the paper, drawn from the estimates cached in audit/*.rds.
# Nothing is estimated here, so a label, a colour or a size changes in seconds
# and never requires a refit. Run after the scripts that write the caches.
#
# Main text
#   fig_design            clock time of sunset and sunrise, Sao Paulo 2018/19,
#                         with and without DST                     (no cache)
#   fig_first_stage       share of PRF crashes recorded dark, by minute from
#                         standard sunset, summer window          (04)
#   fig_hours_from_sunset effect by clock hour relative to standard sunset and
#                         sunrise                                  (02)
#   fig_event_study       hour after sunset vs hour before, by season (03)
# Appendix
#   fig_within_day        event study with state-by-day fixed effects (10, 03)
#   fig_honestdid         Rambachan-Roth sensitivity               (08)
#   fig_assault           assault deaths, whole day and 5-8 p.m.   (11)
#   fig_bahia             Bahia's single DST season, 2011/12       (18)
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
save_fig(g, "fig_design", height = 3.3)

# ── First stage: what the police officer saw ────────────────────────────────
# Share of PRF crashes in treated states, summer window, recorded at dusk or
# night, by 10-minute bin of clock time minus standard-time sunset (plotted at
# the bin midpoint).
fs <- rd("prf_clock_check.rds")$window_curve
FS <- c("With DST, 2009/10–2018/19", "Without DST, 2019/20–2024/25")
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
       y = "Crashes recorded at dusk or night (%)") +
  theme_paper()
save_fig(g, "fig_first_stage", height = 3.2)

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
HB <- c("Hour after sunset (light changed)", "Hour before sunset (light unchanged)")
es <- rd("switched_hour_event_study.rds")$event_study
es[, `:=`(outcome = factor(OUTCOME_LAB[outcome], levels = TRAFFIC_LAB),
          hour = factor(fifelse(bin == 0L, HB[1], HB[2]), levels = HB))]
es[, c("lo", "hi") := ci(coef, se)]
g <- ggplot(es, aes(sy, 100 * coef, colour = hour, shape = hour)) +
  event_frame(es$sy, TRAFFIC_LAB) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, linewidth = 0.5, position = dodge) +
  geom_point(size = 1.8, position = dodge) +
  facet_wrap(~ outcome, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["grey"]]), HB)) +
  scale_shape_manual(values = setNames(c(16, 1), HB)) +
  labs(x = "Season", y = "Relative to 2018/19 (log points)") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_event_study", height = 7)

# ── Appendix: within the day ────────────────────────────────────────────────
WD <- c("Triple difference", "With state-by-day fixed effects")
wd <- rbind(rd("switched_hour_event_study.rds")$event_study[bin == 0L, .(outcome, sy, coef, se, design = WD[1])],
            rd("within_day.rds")$event_study[, .(outcome, sy, coef, se, design = WD[2])])
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
  labs(x = "Season", y = "Hour after sunset, relative to 2018/19 (log points)") +
  theme_paper() + theme_outcome_strip()
save_fig(g, "fig_within_day", height = 7)

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
BL <- c("Whole day", "5–8 p.m.")
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
