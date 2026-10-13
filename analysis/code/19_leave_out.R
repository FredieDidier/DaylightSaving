# =============================================================================
# 19_leave_out.R
#
# The evening light-switched hour (bin 0) under other samples, same Poisson
# triple difference as 01:
#   (a) leave one state out (23 fits per outcome);
#   (b) leave one season out (16 fits per outcome);
#   (c) other control groups: Northeast only, North only;
#   (d) without the La Nina summers (2020/21-2022/23), and without 2019/20,
#       the first season without DST.
# With 11 treated and 12 control states, (a) shows whether one state carries
# the estimate.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))[outcome %in% TRAFFIC]
NE <- c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE")
NO <- c("RO", "RR", "PA", "AP")
stopifnot(setequal(c(NE, NO), CONTROL))

est <- function(p) {
  m <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf, notes = FALSE)
  list(lp = 100 * coef(m)[["twp"]], se = 100 * se(m)[["twp"]])
}

res <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L, "set")
  rbind(
    data.table(outcome = o, kind = "baseline", dropped = "none", as.data.table(est(p))),
    rbindlist(lapply(c(TREATED, CONTROL), function(u)
      data.table(outcome = o, kind = "state", dropped = u, as.data.table(est(p[uf != u]))))),
    rbindlist(lapply(SEASONS, function(s)
      data.table(outcome = o, kind = "season", dropped = season_lab(s), as.data.table(est(p[sy != s]))))),
    data.table(outcome = o, kind = "control", dropped = "North (control = Northeast only)",
               as.data.table(est(p[!uf %in% NO]))),
    data.table(outcome = o, kind = "control", dropped = "Northeast (control = North only)",
               as.data.table(est(p[!uf %in% NE]))),
    data.table(outcome = o, kind = "seasons", dropped = "La Nina summers 2020/21-2022/23",
               as.data.table(est(p[!sy %in% 2020:2022]))),
    data.table(outcome = o, kind = "seasons", dropped = "2019/20",
               as.data.table(est(p[sy != 2019L]))))
}))

saveRDS(res, file.path(path_audit, "leave_out.rds"))
options(width = 160)
print(res[kind %in% c("baseline", "control", "seasons"), lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
print(res[kind %in% c("state", "season"), .(min_lp = round(min(lp), 1), which_min = dropped[which.min(lp)],
                                            max_lp = round(max(lp), 1), which_max = dropped[which.max(lp)]),
          by = .(outcome, kind)])
