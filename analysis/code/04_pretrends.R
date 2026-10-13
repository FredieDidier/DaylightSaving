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
#   (d) pooled estimate without the COVID seasons (2020/21, 2021/22).
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
  nocov  <- est("y ~ twp", p[!sy %in% 2020:2021])
  data.table(outcome = o, bin = b,
             wald_pre_p = w$p,
             pre_trend_lp = 100 * pre_tr$b[["tw:t"]], pre_trend_se = 100 * pre_tr$s[["tw:t"]],
             base_lp = 100 * base$b[["twp"]], base_se = 100 * base$s[["twp"]],
             trend_lp = 100 * trend$b[["twp"]], trend_se = 100 * trend$s[["twp"]],
             nocovid_lp = 100 * nocov$b[["twp"]], nocovid_se = 100 * nocov$s[["twp"]])
}))))

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

saveRDS(list(pretrends = res, missing_hour = miss), file.path(path_audit, "pretrends.rds"))
options(width = 170)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
cat("\nMissing clock time, on-road SIM transport deaths (%):\n")
print(dcast(miss, group + window ~ period, value.var = "miss_pct"))
cat("Triple difference in missing share (pp):", round(miss_ddd, 2), "\n")
