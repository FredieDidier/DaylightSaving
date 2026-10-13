# =============================================================================
# 24_street_lighting.R
#
# Does street lighting substitute for daylight? If abolition kills by taking
# daylight from the evening hour, the effect should be larger where streets
# are dark (Tealde 2022 for crime in Montevideo).
#
# Lighting: share of households on a street face without public lighting
# (build/09_census_lighting.R): Census 2022 (main, the closest to abolition)
# and Census 2010 (urban tracts; robustness). Municipalities are split
# WITHIN each state at the median of that share, weighted by the
# municipality's on-road SIM transport deaths (all hours, all seasons), and
# the comparison is within state. The halves are equal only roughly: the
# municipality that crosses the median goes whole to the darker half, so
# the Federal District (one municipality) is entirely "dark", and in AP and
# RR the capital puts 85-100% of deaths there. Dropping DF or assigning the
# crossing municipality by its midpoint moves no estimate by more than 8 log
# points and no difference to p < 0.15.
#
# Panel: UF x day x half. Poisson triple difference of 01 with every fixed
# effect interacted with the half, and the treatment split by half:
#   y ~ twp:dark + twp:lit | uf^window^half + uf^sy^half + date^half
# Outcomes: SIM on-road transport deaths and pedestrian deaths in evening
# hour 0; the hour before (bin -1, light unchanged) as a placebo.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
lig  <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "census", "output",
                                             "muni_lighting.parquet")))

# Weighted median split within state, one measure at a time.
w0 <- ev[outcome == "SIM transport deaths, on road", .(n = .N), by = .(uf, code6)]
d2 <- rbind(copy(days)[, half := "dark"], copy(days)[, half := "lit"])

run_measure <- function(meas) {
  w <- lig[, .(code6, unlit = get(meas))][w0, on = "code6"]
  missing_deaths <- w[is.na(unlit), sum(n)]
  w <- w[!is.na(unlit)]
  setorder(w, uf, unlit)
  w[, cum := cumsum(n) / sum(n), by = uf]
  w[, half := fifelse(cum <= 0.5, "lit", "dark")]
  split_tab <- w[, .(deaths = sum(n), unlit_pct_mean = weighted.mean(unlit, n)),
                 by = .(group = fifelse(uf %in% TREATED, "treated", "control"), half)]
  e2 <- w[, .(code6, half)][ev, on = "code6", nomatch = 0]
  est <- function(o, b) {
    y <- e2[outcome == o & bin_set == b, .(y = sum(w)), by = .(uf, date, half)]
    p <- y[d2, on = .(uf, date, half)][is.na(y), y := 0]
    p[, `:=`(t_dark = twp * (half == "dark"), t_lit = twp * (half == "lit"))]
    m <- fepois(y ~ t_dark + t_lit | uf^window^half + uf^sy^half + date^half,
                data = p, cluster = ~uf, notes = FALSE)
    b_ <- coef(m); V <- vcov(m)
    dd <- b_[["t_dark"]] - b_[["t_lit"]]
    sd_ <- sqrt(V["t_dark", "t_dark"] + V["t_lit", "t_lit"] - 2 * V["t_dark", "t_lit"])
    data.table(measure = meas, outcome = o, bin = b,
               dark_lp = 100 * b_[["t_dark"]], dark_se = 100 * se(m)[["t_dark"]],
               lit_lp = 100 * b_[["t_lit"]], lit_se = 100 * se(m)[["t_lit"]],
               diff_lp = 100 * dd, diff_se = 100 * sd_, diff_p = 2 * pnorm(-abs(dd / sd_)),
               dark_pre_per_season = p[half == "dark" & tw == 1 & post == 0, sum(y)] / sum(SEASONS <= LAST_PRE),
               lit_pre_per_season = p[half == "lit" & tw == 1 & post == 0, sum(y)] / sum(SEASONS <= LAST_PRE))
  }
  OUT <- c("SIM transport deaths, on road", "SIM pedestrian deaths, on road", "PRF injury accidents")
  list(results = rbindlist(lapply(OUT, function(o) rbind(est(o, 0L), est(o, -1L)))),
       split = split_tab[, measure := meas], missing_deaths = missing_deaths)
}
runs <- lapply(c("unlit_pct_2022", "unlit_pct_2010"), run_measure)
res <- rbindlist(lapply(runs, `[[`, "results"))
split_tab <- rbindlist(lapply(runs, `[[`, "split"))
cat("On-road deaths without lighting data (2022, 2010):", sapply(runs, `[[`, "missing_deaths"), "\n")

saveRDS(list(results = res, split = split_tab), file.path(path_audit, "street_lighting.rds"))
options(width = 180)
print(split_tab)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])
