# =============================================================================
# 27_mexico_within_day.R
#
# Mexico without the control units. In 26_mexico.R the comparison group is
# thin: the six units that kept their clock (Sonora, Quintana Roo, Baja
# California and the border municipalities) have ~20 deaths per summer in
# evening hour 0 and as few as 1-3 per year in the hour before sunset off
# season after 2023, so a swing in them moves the triple difference a lot
# (hour -1: -126 log points with treated-unit raw counts flat).
#
# Here only the treated units (those that lost DST) enter. Within each unit
# and day, the hour after standard-time sunset is compared with the reference
# hours of the Brazilian within-day design (09_within_day.R): 3 to 5 hours
# before sunset (daylight under both regimes) and 2 to 4 after (dark under
# both). Hours -2, -1 and +1 changed light in part (lower sun, twilight), so
# each gets its own coefficient instead of serving as reference:
#   y[u,d,b] ~ sum_k 1[b = k] x window x post | unit^date + unit^bin^window + unit^bin^sy
# Unit-by-day effects absorb anything common to a day (weather, holidays,
# traffic); a coefficient is the change in hour k's share of the day's
# reference-plus-focal events, summer against off-season, after 2023 against
# before. Standard errors clustered by unit.
#
# Two checks of the estimator itself:
#   placebo  the same comparison in the six units that kept their clock
#            (Baja California and the border municipalities on US dates
#            before and after the law, Sonora and Quintana Roo without DST),
#            whose hour 0 did not change light: it should not rise. In
#            Brazil the same estimator in the control states gives +20 log
#            points in hour 0 (09_within_day.R), so it needs this benchmark;
#   no 2020-2021  the treated units without the pandemic years, which fall
#            in the years before abolition here.
# Also the coverage of the register: municipalities with at least one
# accident, accidents and deaths at the scene, by year and group.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

MX  <- file.path(DROPBOX_ROOT, "build", "mexico", "output")
geo <- as.data.table(read_parquet(file.path(MX, "mx_muni_geo.parquet")))[!is.na(lat) & cve_ent != "08"]
acc <- as.data.table(read_parquet(file.path(MX, "atus_accidents.parquet")))[, date := as.IDate(date)]

norm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
geo[, nm := norm(name)]
border <- rbindlist(lapply(names(MX_BORDER), function(e) data.table(cve_ent = e, nm = norm(MX_BORDER[[e]]))))
geo[, border := FALSE][border, border := TRUE, on = .(cve_ent, nm)]
stopifnot(geo[border == TRUE, .N] == 22L)
geo[, std_offset_h := fcase(cve_ent == "02", -8, cve_ent == "23", -5,
                            cve_ent %in% c("03", "25", "26"), -7,
                            cve_ent == "18" & nm != norm("Bahia de Banderas"), -7, default = -6)]
geo[, unit := fcase(cve_ent %in% MX_CONTROL_STATES, cve_ent, border, paste0(cve_ent, "b"), default = cve_ent)]
geo[, group := fifelse(cve_ent %in% MX_CONTROL_STATES | border, "kept clock", "lost DST")]

ev <- geo[, .(cve_ent, cve_mun, unit, group, lat, lon, std_offset_h)][acc, on = .(cve_ent, cve_mun), nomatch = 0]
ev <- ev[!is.na(cmin)]
ev[, bin := floor((cmin - sun_times(date, lat, lon, std_offset_h)$sunset) / 60)]
FOCAL <- -2:1
BINS  <- c(-5:-3, FOCAL, 2:4)
ev <- ev[bin %in% BINS]
ev[, `:=`(o_deaths = deaths, o_ped_deaths = ped_deaths, o_victim_acc = as.integer(victims),
          o_ped_struck = as.integer(victims & ped_crash))]
OUT <- c("Deaths" = "o_deaths", "Pedestrian deaths" = "o_ped_deaths",
         "Accidents with victims" = "o_victim_acc", "Pedestrians struck, with victims" = "o_ped_struck")

days <- CJ(unit = unique(geo$unit), date = seq(as.IDate("2016-01-01"), as.IDate("2025-12-31"), by = "day"),
           bin = BINS)
days <- unique(geo[, .(unit, group)])[days, on = "unit"]
md <- days[, month(date) * 100L + mday(date)]
days[, window := fcase(md >= 408L & md <= 1024L, "win", md >= 1108L | md <= 307L, "off")]
days <- days[!is.na(window)]
days[, sy := year(date)]
days[, wp := as.integer(window == "win") * as.integer(sy >= 2023L)]
fname <- function(k) paste0("f", fifelse(k < 0, paste0("m", abs(k)), paste0("p", k)))
days[, (fname(FOCAL)) := lapply(FOCAL, function(k) as.integer(bin == k) * wp)]

CASES <- data.table(group = c("lost DST", "kept clock", "lost DST"),
                    sample = c("all years", "all years", "without 2020 and 2021"))
res <- rbindlist(lapply(seq_len(nrow(CASES)), function(i) {
  cs <- CASES[i]
  dd <- days[group == cs$group]
  if (cs$sample != "all years") dd <- dd[!sy %in% 2020:2021]
  rbindlist(lapply(names(OUT), function(o) {
    y <- ev[group == cs$group, .(y = sum(get(OUT[[o]]))), by = .(unit, date, bin)]
    p <- y[dd, on = .(unit, date, bin)][is.na(y), y := 0]
    m <- fepois(as.formula(paste("y ~", paste(fname(FOCAL), collapse = " + "),
                                 "| unit^date + unit^bin^window + unit^bin^sy")),
                data = p, cluster = ~unit, notes = FALSE)
    data.table(cs, outcome = o, bin = FOCAL, lp = 100 * coef(m)[fname(FOCAL)],
               se = 100 * se(m)[fname(FOCAL)], p = pvalue(m)[fname(FOCAL)],
               hour0_pre_per_year = p[bin == 0L & window == "win" & sy < 2023, sum(y)] /
                 uniqueN(p[sy < 2023, sy]),
               n_units = uniqueN(p$unit), n_obs = nobs(m))
  }))
}))

coverage <- geo[, .(cve_ent, cve_mun, group)][acc, on = .(cve_ent, cve_mun), nomatch = 0][
  year(date) >= 2016L, .(municipalities = uniqueN(paste(cve_ent, cve_mun)), accidents = .N,
                         deaths = sum(deaths)), keyby = .(group, year = year(date))]
saveRDS(list(results = res, coverage = coverage), file.path(path_audit, "mexico_within_day.rds"))
print(dcast(coverage, year ~ group, value.var = c("municipalities", "accidents", "deaths")))
options(width = 160)
print(res[bin == 0L, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
