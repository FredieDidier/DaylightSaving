# =============================================================================
# 21_record_integrity.R
#
# Did the way deaths are recorded change differentially with abolition? Two
# shares, from all SIM land-transport deaths (V01-V89, any place):
#   on_road   share that occurred on the public road (LOCOCOR = 4); moves if
#             pre-hospital care (SAMU) reaches victims sooner in one region;
#   no_time   among on-road deaths, share without a valid clock time; those
#             deaths never enter the hourly design.
# Cells are UF x season x window (summer window / off-season, as in make_days).
# Test: linear triple difference on the share, cells weighted by deaths,
#   share ~ treated x window x post | uf^window + uf^sy + window^sy,
# standard errors clustered by state.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
sim <- rbindlist(lapply((min(SEASONS)):(max(SEASONS) + 1L), function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "LOCOCOR",
                                            "CAUSABAS", "preliminary")))))
stopifnot(!any(sim$preliminary))
sim <- sim[CAUSABAS >= "V01" & CAUSABAS < "V90"]
sim[, `:=`(uf = code_to_uf[substr(CODMUNOCOR, 1, 2)], date = as.IDate(DTOBITO, format = "%d%m%Y"))]
sim <- unique(days[, .(uf, date, sy, window, treated, post)])[sim, on = .(uf, date), nomatch = 0]
sim[, `:=`(on_road = as.integer(LOCOCOR %in% "4"), no_time = as.integer(is.na(clock_min(HORAOBITO))))]

cells <- rbind(
  sim[, .(measure = "on_road", share = mean(on_road), n = .N), by = .(uf, sy, window, treated, post)],
  sim[on_road == 1L, .(measure = "no_time", share = mean(no_time), n = .N), by = .(uf, sy, window, treated, post)])
cells[, `:=`(win = as.integer(window == "win"))][, twp := treated * win * post]

test <- rbindlist(lapply(c("on_road", "no_time"), function(ms) {
  m <- feols(share ~ twp | uf^window + uf^sy + window^sy, data = cells[measure == ms],
             weights = ~n, cluster = ~uf)
  data.table(measure = ms, pp = 100 * coef(m)[["twp"]], se_pp = 100 * se(m)[["twp"]],
             p = pvalue(m)[["twp"]], mean_pct = 100 * cells[measure == ms, weighted.mean(share, n)])
}))
series <- cells[, .(share = 100 * sum(share * n) / sum(n), n = sum(n)),
                by = .(measure, group = fifelse(treated == 1L, "treated", "control"), window, sy)]

saveRDS(list(test = test, series = series), file.path(path_audit, "record_integrity.rds"))
options(width = 160)
print(test[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
print(dcast(series[window == "win"], sy ~ measure + group, value.var = "share")[, lapply(.SD, round, 1)])
