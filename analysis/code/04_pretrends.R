# =============================================================================
# 04_pretrends.R
#
# Parallel-trends diagnostics for the light-switched evening hour (bin 0) and
# the hour before it (bin -1), traffic outcomes.
#
# The identifying assumption of the triple difference is that, absent the
# abolition, the gap  (treated - control) x (DST window - off season)  would
# have stayed on its pre-2019 path. Four checks:
#   (a) joint Wald test that all pre-period event-study coefficients are zero
#       (reference 2018/19);
#   (b) linear trend in that gap estimated on pre-period data only;
#   (c) pooled estimate with and without a linear treated x window trend
#       fitted on the whole sample (05_imputation.R does the cleaner version:
#       trend fitted on untreated observations only, then extrapolated);
#   (d) pooled estimate without the pandemic: every date from March 2020 to
#       February 2022 (PANDEMIC, 00_utils.R), which includes the lockdown
#       months that fall in the off-season of 2019/20;
#   (e) the effect in the first two seasons without DST (2019/20, 2020/21)
#       and in the last three, with and without the pandemic dates;
#   (f) the summer window alone: a difference in differences, treated against
#       control states, after against before, with state and date effects.
#       It leaves out the off-season comparison and so any shock confined to
#       the off-season;
#   (g) the two legs of the triple difference season by season: the treated -
#       control gap in the summer window and in the off-season, each against
#       2018/19 (figure: the source of the season-to-season swings).
# Also: share of on-road SIM transport deaths with missing clock time, by
# group, window and period (missing hours drop out of every bin).
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))

est <- function(f, d) {
  m <- fepois(as.formula(paste(f, FE)), data = d, cluster = ~uf)
  list(m = m, b = coef(m), s = se(m))
}
pre_terms <- sprintf("sy::(%s):tw", paste(SEASONS[SEASONS < LAST_PRE], collapse = "|"))

res <- rbindlist(lapply(TRAFFIC, function(o) rbindlist(lapply(c(0L, -1L), function(b) {
  p <- make_panel(ev, days, o, b)
  es <- est("y ~ i(sy, tw, ref = LAST_PRE)", p)$m
  w  <- wald(es, keep = pre_terms, print = FALSE)
  pre_tr <- est("y ~ tw:t", p[post == 0])
  base   <- est("y ~ twp", p)
  trend  <- est("y ~ twp + tw:t", p)
  nopan  <- est("y ~ twp", drop_pandemic(p))
  p[, `:=`(early = twp * (sy <= LAST_PRE + 2L), late = twp * (sy > LAST_PRE + 2L))]
  el     <- est("y ~ early + late", p)
  el_np  <- est("y ~ early + late", drop_pandemic(p))
  s <- p[window == "win"][, `:=`(tp = treated * post, early = treated * post * (sy <= LAST_PRE + 2L),
                                 late = treated * post * (sy > LAST_PRE + 2L))]
  fs <- function(f, d) fepois(as.formula(f), data = d, cluster = ~uf, notes = FALSE)
  sdd <- fs("y ~ tp | uf + date", s)
  sel <- fs("y ~ early + late | uf + date", s)
  data.table(outcome = o, bin = b,
             wald_pre_p = w$p,
             pre_trend_lp = 100 * pre_tr$b[["tw:t"]], pre_trend_se = 100 * pre_tr$s[["tw:t"]],
             base_lp = 100 * base$b[["twp"]], base_se = 100 * base$s[["twp"]],
             trend_lp = 100 * trend$b[["twp"]], trend_se = 100 * trend$s[["twp"]],
             nopandemic_lp = 100 * nopan$b[["twp"]], nopandemic_se = 100 * nopan$s[["twp"]],
             early_lp = 100 * el$b[["early"]], early_se = 100 * el$s[["early"]],
             late_lp = 100 * el$b[["late"]], late_se = 100 * el$s[["late"]],
             early_nopan_lp = 100 * el_np$b[["early"]], early_nopan_se = 100 * el_np$s[["early"]],
             late_nopan_lp = 100 * el_np$b[["late"]], late_nopan_se = 100 * el_np$s[["late"]],
             summer_dd_lp = 100 * coef(sdd)[["tp"]], summer_dd_se = 100 * se(sdd)[["tp"]],
             summer_early_lp = 100 * coef(sel)[["early"]], summer_early_se = 100 * se(sel)[["early"]],
             summer_late_lp = 100 * coef(sel)[["late"]], summer_late_se = 100 * se(sel)[["late"]])
}))))

# ── (g) The two legs, season by season ──────────────────────────────────────
legs <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L)
  rbindlist(lapply(c("win", "off"), function(wn) {
    m <- fepois(y ~ i(sy, treated, ref = LAST_PRE) | uf + date, data = p[window == wn],
                cluster = ~uf, notes = FALSE)
    rbind(data.table(outcome = o, window = wn,
                     sy = as.integer(sub("sy::(\\d+):treated", "\\1", names(coef(m)))),
                     coef = coef(m), se = se(m)),
          data.table(outcome = o, window = wn, sy = LAST_PRE, coef = 0, se = 0))
  }))
}))

# Missing clock time among on-road SIM transport deaths.
yrs <- (min(SEASONS)):(max(SEASONS) + 1L)
sim <- rbindlist(lapply(yrs, function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "LOCOCOR",
                                            "CAUSABAS")))))
sim <- sim[LOCOCOR == "4" & CAUSABAS >= "V01" & CAUSABAS < "V90"]
sim[, `:=`(uf = code_to_uf[substr(CODMUNOCOR, 1, 2)], date = as.IDate(DTOBITO, format = "%d%m%Y"),
           miss = as.integer(is.na(HORAOBITO) | nchar(HORAOBITO) != 4L))]
sim <- days[, .(uf, date, window, post)][sim, on = .(uf, date), nomatch = 0]
miss <- sim[, .(miss_pct = round(100 * mean(miss), 1), n = .N),
            by = .(group = fifelse(uf %in% TREATED, "treated", "control"), window,
                   period = fifelse(post == 1, "post", "pre"))]
miss_ddd <- miss[, sum(miss_pct * fifelse(group == "treated", 1, -1) *
                         fifelse(window == "win", 1, -1) * fifelse(period == "post", 1, -1))]

saveRDS(list(pretrends = res, legs = legs, missing_hour = miss), file.path(path_audit, "pretrends.rds"))
options(width = 170)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
cat("\nMissing clock time, on-road SIM transport deaths (%):\n")
print(dcast(miss, group + window ~ period, value.var = "miss_pct"))
cat("Triple difference in missing share (pp):", round(miss_ddd, 2), "\n")
