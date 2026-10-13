# =============================================================================
# 08_wider_window.R
#
# Does widening the evening window buy precision without losing the signal?
# The single light-switched hour is noisy season by season (~110 on-road SIM
# deaths per season in treated states), which is what drives the HonestDiD
# breakdown values in 07_honestdid.R. Abolition also changed light in the neighbouring
# hours, only less sharply:
#   bin -1  [-60, 0)    mid-afternoon sun under DST -> last, low-sun hour
#   bin  0  [0, 60)     daylight -> dark (the sharp switch)
#   bin  1  [60, 120)   twilight -> full dark
# Windows compared (minutes relative to standard-time sunset):
#   A [0, 60)     the switched hour (baseline)
#   B [0, 120)    switched hour + the one after (both got darker)
#   C [-60, 120)  the whole dusk; nets out any within-dusk reallocation
# For each: pooled Poisson triple difference (SE by UF), joint pre-trend Wald,
# pre-period linear trend, and HonestDiD smoothness CIs for the average post
# effect with breakdown value.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(HonestDiD)
})

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
pre_s  <- SEASONS[SEASONS < LAST_PRE]
post_s <- SEASONS[SEASONS > LAST_PRE]
l_avg  <- rep(1 / length(post_s), length(post_s))
WINDOWS <- list(`A [0,60)` = 0L, `B [0,120)` = 0:1, `C [-60,120)` = -1:1)
M_GRID <- c(0, 0.01, 0.02, 0.03, 0.05, 0.075, 0.10)

window_panel <- function(outc, bins) {
  sel <- ev[["outcome"]] == outc & ev[["bin_set"]] %in% bins
  y <- ev[sel, .(y = sum(w)), by = .(uf, date)]
  p <- y[days, on = .(uf, date)]
  p[is.na(y), y := 0]
  p[]
}

res <- rbindlist(lapply(TRAFFIC, function(o) rbindlist(lapply(names(WINDOWS), function(wn) {
  p <- window_panel(o, WINDOWS[[wn]])
  base <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf)
  es   <- fepois(as.formula(paste("y ~ i(sy, tw, ref = LAST_PRE)", FE)), data = p, cluster = ~uf)
  wald_p <- wald(es, keep = sprintf("sy::(%s):tw", paste(pre_s, collapse = "|")), print = FALSE)$p
  pre_tr <- fepois(as.formula(paste("y ~ tw:t", FE)), data = p[post == 0], cluster = ~uf)
  keep <- paste0("sy::", c(pre_s, post_s), ":tw")
  b <- coef(es)[keep]; V <- vcov(es)[keep, keep]
  sd <- as.data.table(createSensitivityResults(betahat = b, sigma = V,
                                               numPrePeriods = length(pre_s),
                                               numPostPeriods = length(post_s),
                                               Mvec = M_GRID, l_vec = l_avg))
  inc0 <- sd[lb <= 0 & ub >= 0]
  data.table(outcome = o, window = wn,
             n_treated_win_pre = p[tw == 1 & post == 0, sum(y)],
             base_lp = 100 * coef(base)[["twp"]], base_se = 100 * se(base)[["twp"]],
             wald_pre_p = wald_p,
             pre_trend_lp = 100 * coef(pre_tr)[["tw:t"]], pre_trend_se = 100 * se(pre_tr)[["tw:t"]],
             sd_pre_coefs_lp = 100 * sd(b[paste0("sy::", pre_s, ":tw")]),
             honest_M0 = sprintf("[%.1f, %.1f]", 100 * sd$lb[sd$M == 0], 100 * sd$ub[sd$M == 0]),
             breakdown_M = if (nrow(inc0)) min(inc0$M) else NA_real_)
}))))

saveRDS(res, file.path(path_audit, "wider_window.rds"))
options(width = 180)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
