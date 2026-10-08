# =============================================================================
# 08_honestdid.R
#
# Rambachan & Roth (2023) sensitivity analysis for the light-switched evening
# hour. Input: the Poisson event study by season (reference 2018/19, the last
# DST season; coefficients in log points, vcov clustered by UF). Target: the
# average effect over the five post-abolition seasons.
#
# Two kinds of restriction on how far the post-period violation of parallel
# trends may stray:
#   - Smoothness (DeltaSD): the slope of the violation may change by at most M
#     log points per season between consecutive seasons. M = 0 is exactly
#     "extrapolate the pre-period linear trend"; larger M allows curvature.
#   - Relative magnitudes (DeltaRM): a post-period violation may be at most
#     Mbar times the largest season-to-season violation seen before 2019.
# The breakdown value is the smallest M (or Mbar) at which the robust 95% CI
# includes zero.
#
# Package: HonestDiD (github.com/asheshrambachan/HonestDiD).
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(HonestDiD)
  library(ggplot2)
})

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
pre_s  <- SEASONS[SEASONS < LAST_PRE]
post_s <- SEASONS[SEASONS > LAST_PRE]
l_avg  <- rep(1 / length(post_s), length(post_s))

M_GRID    <- c(0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.10)
MBAR_GRID <- c(0, 0.25, 0.5, 0.75, 1, 1.5, 2)

breakdown <- function(tab, col) {
  inc0 <- tab[lb <= 0 & ub >= 0]
  if (nrow(inc0)) min(inc0[[col]]) else NA_real_
}

out <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L)
  m <- fepois(as.formula(paste("y ~ i(sy, tw, ref = LAST_PRE)", FE)), data = p, cluster = ~uf)
  keep <- paste0("sy::", c(pre_s, post_s), ":tw")
  stopifnot(all(keep %in% names(coef(m))))
  b <- coef(m)[keep]
  V <- vcov(m)[keep, keep]

  orig <- as.data.table(constructOriginalCS(betahat = b, sigma = V,
                                            numPrePeriods = length(pre_s),
                                            numPostPeriods = length(post_s), l_vec = l_avg))
  sd <- as.data.table(createSensitivityResults(betahat = b, sigma = V,
                                               numPrePeriods = length(pre_s),
                                               numPostPeriods = length(post_s),
                                               Mvec = M_GRID, l_vec = l_avg))
  rm_ <- as.data.table(createSensitivityResults_relativeMagnitudes(
    betahat = b, sigma = V, numPrePeriods = length(pre_s), numPostPeriods = length(post_s),
    Mbarvec = MBAR_GRID, l_vec = l_avg))

  rbind(orig[, .(outcome = o, restriction = "original", param = NA_real_, lb, ub)],
        sd[,  .(outcome = o, restriction = "smoothness (M)", param = M, lb, ub)],
        rm_[, .(outcome = o, restriction = "relative magnitude (Mbar)", param = Mbar, lb, ub)])[
    , `:=`(avg_post_lp = 100 * sum(l_avg * b[paste0("sy::", post_s, ":tw")]),
           breakdown_M = breakdown(sd, "M"), breakdown_Mbar = breakdown(rm_, "Mbar"))][]
}))

saveRDS(out, file.path(path_audit, "honestdid.rds"))

# ── Figure ──────────────────────────────────────────────────────────────────
# Columns: the two restrictions; x: how far the violation may stray (the
# conventional CI first, at "PT", parallel trends). Rows: outcomes. Strip
# labels are plotmath, so M-bar is drawn as a real bar over M.
RESTR <- c("smoothness (M)"            = "Smoothness~(italic(M))",
           "relative magnitude (Mbar)" = "Relative~magnitude~(italic(bar(M)))")
orig <- out[restriction == "original", .(outcome, lb, ub)]
fig <- rbind(
  orig[rep(seq_len(.N), each = 2)][, `:=`(restriction = rep(names(RESTR), .N / 2), x = "PT",
                                          kind = "Conventional (parallel trends)")],
  out[restriction != "original", .(outcome, lb, ub, restriction,
                                   x = format(param, drop0trailing = TRUE, trim = TRUE),
                                   kind = "Robust (HonestDiD)")])
OUT_PARSED <- c("Road~deaths~(SIM)", "Highway~deaths~(PRF)", "Injury~crashes~(PRF)")
fig[, outcome := factor(OUT_PARSED[match(outcome, TRAFFIC)], levels = OUT_PARSED)]
fig[, restriction := factor(RESTR[restriction], levels = RESTR)]
fig[, x := factor(x, levels = unique(c("PT", format(sort(unique(c(M_GRID, MBAR_GRID))),
                                                    drop0trailing = TRUE, trim = TRUE))))]
fig[, kind := factor(kind, levels = c("Conventional (parallel trends)", "Robust (HonestDiD)"))]
g <- ggplot(fig, aes(x, ymin = 100 * lb, ymax = 100 * ub, colour = kind, linetype = kind)) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_linerange(linewidth = 0.9) +
  # Free y per panel: the relative-magnitude bounds run to +-500 lp and would
  # flatten the smoothness panels on a shared scale.
  facet_wrap(~ outcome + restriction, ncol = 2, scales = "free",
             labeller = label_parsed) +
  scale_y_continuous(labels = num_lab) +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["blue"]]), levels(fig$kind))) +
  scale_linetype_manual(values = setNames(c("solid", "solid"), levels(fig$kind))) +
  labs(x = "Allowed deviation from parallel trends (PT = none)",
       y = "95% CI, average post effect (log points)") +
  theme_paper() +
  theme(axis.text.x = element_text(size = 8))
save_fig(g, "fig04_honestdid", height = 6.6)

options(width = 160)
print(out[, .(outcome, restriction, param, lb_lp = round(100 * lb, 1), ub_lp = round(100 * ub, 1),
              avg_post_lp = round(avg_post_lp, 1), breakdown_M, breakdown_Mbar)])
