# =============================================================================
# 17_placebo_hours.R
#
# Placebo against a sleep channel: hours far from sunrise and sunset, whose
# light did not change with abolition. A chronic sleep effect (social jetlag)
# would move crashes at every hour, above all early morning and late night; a
# light effect only at dusk and dawn. Same Poisson triple difference as 01:
#   y[u,d] ~ treated x window x post | uf^window + uf^sy + date
# Blocks (60-minute bins relative to STANDARD-time sunrise / sunset):
#   midday  bin_rise >= 3 and bin_set <= -4  (sun well up under both regimes)
#   night   bin_set >= 3 (until midnight) or bin_rise <= -3 (after it); dark
# The light-switched evening hour (bin_set = 0) is printed alongside.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))[outcome %in% TRAFFIC]
ev[, block := fcase(bin_set == 0, "evening hour 0 (light changed)",
                    bin_rise >= 3 & bin_set <= -4, "midday (light unchanged)",
                    bin_set >= 3 | bin_rise <= -3, "night (light unchanged)")]

res <- rbindlist(lapply(TRAFFIC, function(o) rbindlist(lapply(
  c("evening hour 0 (light changed)", "midday (light unchanged)", "night (light unchanged)"), function(b) {
    y <- ev[outcome == o & block %in% b, .(y = sum(w)), by = .(uf, date)]
    p <- y[days, on = .(uf, date)][is.na(y), y := 0]
    m <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf, notes = FALSE)
    data.table(outcome = o, block = b, lp = 100 * coef(m)[["twp"]], se = 100 * se(m)[["twp"]],
               p = pvalue(m)[["twp"]], treated_win_pre_per_season =
                 p[tw == 1 & post == 0, sum(y)] / sum(SEASONS <= LAST_PRE))
  }))))

saveRDS(res, file.path(path_audit, "placebo_hours.rds"))
options(width = 160)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
