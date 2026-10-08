# =============================================================================
# 03_switched_hour_event_study.R
#
# Event study for the light-switched evening hour (bin 0 relative to standard
# sunset) and the hour before it (bin -1). Same Poisson triple difference as
# 02_sunset_design.R, with treated x window interacted with each season
# (reference 2018/19, the last DST season).
#
# Also a placebo in time: the pooled estimate is compared with the estimates
# obtained by pretending abolition happened in each pre-period season, using
# pre-period data only.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(ggplot2)
})

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))

es <- rbindlist(lapply(TRAFFIC, function(o) rbindlist(lapply(c(0L, -1L), function(b) {
  p <- make_panel(ev, days, o, b)
  m <- fepois(as.formula(paste("y ~ i(sy, tw, ref = LAST_PRE)", FE)), data = p, cluster = ~uf)
  ct <- as.data.table(coeftable(m), keep.rownames = "term")
  rbind(ct[, .(outcome = o, bin = b, sy = as.integer(sub("sy::(\\d+):tw", "\\1", term)),
               coef = Estimate, se = `Std. Error`)],
        data.table(outcome = o, bin = b, sy = LAST_PRE, coef = 0, se = 0))
}))))

fake_years <- (min(SEASONS) + 2L):(LAST_PRE - 1L)
plac <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L)
  real <- coef(fepois(as.formula(paste("y ~ twp", FE)), data = p))[["twp"]]
  pre  <- p[post == 0]
  fake <- sapply(fake_years, function(s) {
    pre[, fp := tw * (sy >= s)]
    coef(fepois(as.formula(paste("y ~ fp", FE)), data = pre))[["fp"]]
  })
  data.table(outcome = o, real = real, fake_min = min(fake), fake_max = max(fake),
             n_fake = length(fake), n_fake_larger = sum(abs(fake) >= abs(real)))
}))

# ── Figure ──────────────────────────────────────────────────────────────────
fig <- copy(es)
fig[, outcome := factor(OUTCOME_LAB[outcome], levels = OUTCOME_LAB)]
fig[, hour := factor(fifelse(bin == 0, "Hour after sunset (light changed)", "Hour before sunset"),
                     levels = c("Hour after sunset (light changed)", "Hour before sunset"))]
dodge <- position_dodge(width = 0.5)
g <- ggplot(fig, aes(sy, 100 * coef, colour = hour, shape = hour)) +
  annotate("rect", xmin = LAST_PRE + 0.5, xmax = max(SEASONS) + 0.5, ymin = -Inf, ymax = Inf,
           fill = "grey93") +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_errorbar(aes(ymin = 100 * (coef - 1.96 * se), ymax = 100 * (coef + 1.96 * se)),
                width = 0, linewidth = 0.5, position = dodge) +
  geom_point(size = 1.9, position = dodge) +
  facet_wrap(~ outcome, ncol = 1, scales = "free_y") +
  scale_x_continuous(breaks = seq(min(SEASONS), max(SEASONS), 2), labels = season_lab,
                     expand = expansion(add = 0.4)) +
  scale_y_continuous(labels = num_lab) +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["grey"]]), levels(fig$hour))) +
  scale_shape_manual(values = setNames(c(16, 1), levels(fig$hour))) +
  labs(x = "Season (shaded: after abolition; reference 2018/19)",
       y = "Treated \u00d7 summer window (log points)") +
  theme_paper()
save_fig(g, "fig03_switched_hour_event_study", height = 7.2)

saveRDS(list(event_study = es, placebo = plac), file.path(path_audit, "switched_hour_event_study.rds"))
options(width = 150)
w <- dcast(es, sy ~ outcome + bin, value.var = "coef")
print(w[, lapply(.SD, function(x) round(100 * x, 1)), by = sy])
print(plac[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
