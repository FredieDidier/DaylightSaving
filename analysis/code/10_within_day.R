# =============================================================================
# 10_within_day.R
#
# Quadruple difference within the day. The triple difference in 02-08 uses one
# clock hour per UF-day, so every daily shock to a state's traffic (rain, a
# holiday, volume) lands in the residual, and season-by-season coefficients
# swing by +-15-30 log points. Here the panel is UF x day x hour relative to the
# sun, and a UF x day fixed effect absorbs every such shock: the light-switched
# hour is compared with hours of the SAME state and day whose light did not
# change.
#
#   y[u,d,b] ~ sum_k 1[b = k] x treated x window x post
#              | uf^date + uf^bin^window + uf^bin^sy + bin^date
#
# The last three are the triple-difference fixed effects, bin by bin; with
# uf^date on top, a coefficient is the change in the share of the state-day's
# events that falls in hour k, relative to the reference hours.
#
# Hours (60-minute bins relative to STANDARD-time sunset / sunrise, as in 02):
#   evening  focal -2, -1, 0, +1   reference -5..-3 (daylight under both
#            regimes) and +2..+4 (dark under both)
#   morning  focal -1, 0, +1       reference -4..-2 (dark under both) and
#            +2..+4 (daylight under both)
# Bin 0 is the hour whose light flipped. -1 / +1 (and evening -2) changed
# light only in part (sun lower, twilight), so they get their own coefficient
# instead of serving as reference.
#
# Also: event study by season for bin 0 (reference 2018/19), HonestDiD on it,
# robustness to the reference set (day only / night only), and (optional, DS_RI)
# randomization inference over which 11 states are treated.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(HonestDiD)
  library(ggplot2)
})

# Randomization inference refits the model once per draw (~35 s each here), so
# it is off by default; DS_RI=199 runs it (about two hours per outcome).
N_RI <- as.integer(Sys.getenv("DS_RI", unset = "0"))
set.seed(20190425)                       # Decree 9,772

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
pre_s  <- SEASONS[SEASONS < LAST_PRE]
post_s <- SEASONS[SEASONS > LAST_PRE]

SIDES <- list(
  set  = list(col = "bin_set",  focal = c(-2L, -1L, 0L, 1L), ref = c(-5:-3, 2:4)),
  rise = list(col = "bin_rise", focal = c(-1L, 0L, 1L),      ref = c(-4:-2, 2:4)))
FE4 <- "| uf^date + uf^bin^window + uf^bin^sy + bin^date"
bname <- function(k) paste0("b", fifelse(k < 0, paste0("m", abs(k)), paste0("p", k)))

# UF x day x bin counts, zeros filled. UF-days with no event in any bin carry
# no information under the uf^date fixed effect and are dropped by fepois.
make_panel4 <- function(outc, side, bins) {
  s <- SIDES[[side]]
  sel <- ev[["outcome"]] == outc & ev[[s$col]] %in% bins
  y <- ev[sel, .(y = sum(w)), by = c("uf", "date", s$col)]
  setnames(y, s$col, "bin")
  grid <- days[, .(bin = bins), by = .(uf, date, window, sy, treated, win, post, tw, twp)]
  p <- y[grid, on = .(uf, date, bin)]
  p[is.na(y), y := 0]
  p[, (bname(s$focal)) := lapply(s$focal, function(k) as.integer(bin == k) * twp)]
  p[, b0tw := as.integer(bin == 0L) * tw]
  p[]
}

fit4 <- function(p, side) {
  f <- as.formula(paste("y ~", paste(bname(SIDES[[side]]$focal), collapse = " + "), FE4))
  fepois(f, data = p, cluster = ~uf, notes = FALSE)
}

cases <- CJ(outcome = TRAFFIC, side = c("set", "rise"), sorted = FALSE)

# ── Pooled estimates, three reference sets ──────────────────────────────────
pooled <- rbindlist(lapply(seq_len(nrow(cases)), function(i) {
  cs <- cases[i]; s <- SIDES[[cs$side]]
  refs <- list(all = s$ref, early = s$ref[s$ref < 0], late = s$ref[s$ref > 0])
  rbindlist(lapply(names(refs), function(r) {
    p <- make_panel4(cs$outcome, cs$side, sort(c(s$focal, refs[[r]])))
    m <- fit4(p, cs$side)
    data.table(cs, reference = r, bin = s$focal, coef = coef(m)[bname(s$focal)],
               se = se(m)[bname(s$focal)], n_obs = nobs(m),
               n_events_bin0_treated_win_pre = p[bin == 0L & tw == 1 & post == 0, sum(y)])
  }))
}))
pooled[, `:=`(pct = 100 * (exp(coef) - 1), p = 2 * pnorm(-abs(coef / se)))]

# ── Event study for evening bin 0, and HonestDiD ────────────────────────────
M_GRID    <- c(0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.10)
MBAR_GRID <- c(0, 0.25, 0.5, 0.75, 1, 1.5, 2)
l_avg <- rep(1 / length(post_s), length(post_s))
breakdown <- function(tab, col) {
  inc0 <- tab[lb <= 0 & ub >= 0]
  if (nrow(inc0)) min(inc0[[col]]) else NA_real_
}

es_hd <- lapply(TRAFFIC, function(o) {
  s <- SIDES$set
  p <- make_panel4(o, "set", sort(c(s$focal, s$ref)))
  # Other focal bins keep their pooled post effect so that bin 0's season
  # coefficients are not contaminated by them.
  others <- setdiff(bname(s$focal), "bp0")
  f <- as.formula(paste("y ~ i(sy, b0tw, ref = LAST_PRE) +", paste(others, collapse = " + "), FE4))
  m <- fepois(f, data = p, cluster = ~uf, notes = FALSE)
  keep <- paste0("sy::", c(pre_s, post_s), ":b0tw")
  stopifnot(all(keep %in% names(coef(m))))
  b <- coef(m)[keep]; V <- vcov(m)[keep, keep]
  es <- rbind(data.table(outcome = o, sy = c(pre_s, post_s), coef = b, se = sqrt(diag(V))),
              data.table(outcome = o, sy = LAST_PRE, coef = 0, se = 0))
  # Joint test that the pre-period season coefficients are zero, from b and V.
  # With 23 clusters a cluster-robust Wald over 10 coefficients tends to
  # over-reject; read it with the HonestDiD bounds, not alone.
  pre_k <- paste0("sy::", pre_s, ":b0tw")
  w_stat <- drop(t(b[pre_k]) %*% solve(V[pre_k, pre_k], b[pre_k]))
  wald_p <- pchisq(w_stat, df = length(pre_k), lower.tail = FALSE)
  orig <- as.data.table(constructOriginalCS(betahat = b, sigma = V, numPrePeriods = length(pre_s),
                                            numPostPeriods = length(post_s), l_vec = l_avg))
  sd <- as.data.table(createSensitivityResults(betahat = b, sigma = V,
                                               numPrePeriods = length(pre_s),
                                               numPostPeriods = length(post_s),
                                               Mvec = M_GRID, l_vec = l_avg))
  rm_ <- as.data.table(createSensitivityResults_relativeMagnitudes(
    betahat = b, sigma = V, numPrePeriods = length(pre_s), numPostPeriods = length(post_s),
    Mbarvec = MBAR_GRID, l_vec = l_avg))
  hd <- rbind(orig[, .(outcome = o, restriction = "original", param = NA_real_, lb, ub)],
              sd[,  .(outcome = o, restriction = "smoothness (M)", param = M, lb, ub)],
              rm_[, .(outcome = o, restriction = "relative magnitude (Mbar)", param = Mbar, lb, ub)])
  hd[, `:=`(avg_post_lp = 100 * sum(l_avg * b[paste0("sy::", post_s, ":b0tw")]),
            pre_sd_lp = 100 * sd(b[paste0("sy::", pre_s, ":b0tw")]),
            wald_pre_p = wald_p,
            breakdown_M = breakdown(sd, "M"), breakdown_Mbar = breakdown(rm_, "Mbar"))]
  hd[, wald_pre_stat := w_stat]
  list(es = es, hd = hd, V = V)
})
es <- rbindlist(lapply(es_hd, `[[`, "es"))
hd <- rbindlist(lapply(es_hd, `[[`, "hd"))
V_es <- setNames(lapply(es_hd, `[[`, "V"), TRAFFIC)

# ── Randomization inference, evening bin 0, full reference set ──────────────
# Real and permuted statistics come from the same model, with the bin-0 term
# alone (a permuted assignment has no meaning for the other focal bins).
ALL <- c(TREATED, CONTROL)
ri <- if (N_RI > 0) rbindlist(lapply(TRAFFIC, function(o) {
  s <- SIDES$set
  p <- make_panel4(o, "set", sort(c(s$focal, s$ref)))
  b_real <- coef(fepois(as.formula(paste("y ~ bp0", FE4)), data = p, notes = FALSE))[["bp0"]]
  perm <- replicate(N_RI, {
    fake <- sample(ALL, length(TREATED))
    p[, fk := as.integer(bin == 0L & uf %in% fake) * win * post]
    coef(fepois(as.formula(paste("y ~ fk", FE4)), data = p, notes = FALSE))[["fk"]]
  })
  data.table(outcome = o, coef_bin0_alone = b_real, ri_p = mean(abs(perm) >= abs(b_real)),
             ri_rank = sprintf("%d of %d", sum(abs(perm) >= abs(b_real)), N_RI))
})) else NULL

saveRDS(list(pooled = pooled, event_study = es, event_study_vcov = V_es, honestdid = hd, ri = ri,
             seasons = SEASONS,
             n_ri = N_RI),
        file.path(path_audit, "within_day.rds"))

# ── Figure: season event study, triple vs quadruple difference ──────────────
es3 <- readRDS(file.path(path_audit, "switched_hour_event_study.rds"))$event_study[bin == 0L]
fig <- rbind(es3[, .(outcome, sy, coef, se, design = "Triple difference (bin 0 alone)")],
             es[, .(outcome, sy, coef, se, design = "Within the day (UF × day fixed effect)")])
fig[, outcome := factor(OUTCOME_LAB[outcome], levels = OUTCOME_LAB)]
fig[, design := factor(design, levels = unique(design))]
dodge <- position_dodge(width = 0.5)
g <- ggplot(fig, aes(sy, 100 * coef, colour = design, shape = design)) +
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
  scale_colour_manual(values = setNames(c(PAL[["grey"]], PAL[["red"]]), levels(fig$design))) +
  scale_shape_manual(values = setNames(c(1, 16), levels(fig$design))) +
  labs(x = "Season (shaded: after abolition; reference 2018/19)",
       y = "Hour after sunset, treated × summer (log points)") +
  theme_paper()
save_fig(g, "fig05_within_day_event_study", height = 7.2)

options(width = 170)
cat("Seasons:", min(SEASONS), "-", max(SEASONS), "\n\nPooled (log points):\n")
print(pooled[, .(outcome, side, reference, bin, lp = round(100 * coef, 1), se = round(100 * se, 1),
                 pct = round(pct, 1), p = round(p, 3), n_obs)])
cat("\nHonestDiD, evening bin 0:\n")
print(hd[restriction == "original" | param %in% c(0, 0.01, 0.02, 0.05, 0.25, 0.5),
         .(outcome, restriction, param, lb = round(100 * lb, 1), ub = round(100 * ub, 1),
           avg_post_lp = round(avg_post_lp, 1), pre_sd_lp = round(pre_sd_lp, 1),
           wald_pre_p = round(wald_pre_p, 3), breakdown_M, breakdown_Mbar)])
if (!is.null(ri)) {
  cat("\nRandomization inference, evening bin 0:\n")
  print(ri)
}
