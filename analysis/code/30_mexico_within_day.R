# =============================================================================
# 30_mexico_within_day.R
#
# Mexico without the control units. In 29_mexico.R the comparison group is
# thin: the six units that kept their clock (Sonora, Quintana Roo, Baja
# California and the border municipalities) have ~20 deaths per summer in
# evening hour 0 and as few as 1-3 per year in the hour before sunset off
# season after 2023, so a swing in them moves the triple difference a lot
# (hour -1: -126 log points with treated-unit raw counts flat).
#
# Here only the treated units (those that lost DST) enter. Within each unit
# and day, the hour after standard-time sunset is compared with the two hours
# before it, whose light did not change:
#   y[u,d,h] ~ h0 x window x post | unit^date + unit^h0^window + unit^h0^sy
# with h0 = 1 for the hour after sunset. Unit-by-day effects absorb anything
# common to the evening of a day (weather, holidays, traffic); the estimate is
# the change in the hour-0 share of the evening, summer against off-season,
# after 2023 against before. Standard errors clustered by unit.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

MX  <- file.path(DROPBOX_ROOT, "build", "mexico", "output")
geo <- as.data.table(read_parquet(file.path(MX, "mx_muni_geo.parquet")))[!is.na(lat) & cve_ent != "08"]
acc <- as.data.table(read_parquet(file.path(MX, "atus_accidents.parquet")))[, date := as.IDate(date)]

norm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
BORDER <- list(
  "05" = c("Acuna", "Allende", "Guerrero", "Hidalgo", "Jimenez", "Morelos", "Nava", "Ocampo",
           "Piedras Negras", "Villa Union", "Zaragoza"),
  "19" = c("Anahuac"),
  "28" = c("Nuevo Laredo", "Guerrero", "Mier", "Miguel Aleman", "Camargo", "Gustavo Diaz Ordaz",
           "Reynosa", "Rio Bravo", "Valle Hermoso", "Matamoros"))
geo[, nm := norm(name)]
border <- rbindlist(lapply(names(BORDER), function(e) data.table(cve_ent = e, nm = norm(BORDER[[e]]))))
geo[, border := FALSE][border, border := TRUE, on = .(cve_ent, nm)]
stopifnot(geo[border == TRUE, .N] == 22L)
geo[, std_offset_h := fcase(cve_ent == "02", -8, cve_ent == "23", -5,
                            cve_ent %in% c("03", "25", "26"), -7,
                            cve_ent == "18" & nm != norm("Bahia de Banderas"), -7, default = -6)]
geo <- geo[!(cve_ent %in% c("02", "23", "26") | border)]       # treated units only
geo[, unit := cve_ent]

ev <- geo[, .(cve_ent, cve_mun, unit, lat, lon, std_offset_h)][acc, on = .(cve_ent, cve_mun), nomatch = 0]
ev <- ev[!is.na(cmin)]
ev[, bin := floor((cmin - sun_times(date, lat, lon, std_offset_h)$sunset) / 60)]
ev <- ev[bin %in% -2:0]
ev[, `:=`(o_deaths = deaths, o_ped_deaths = ped_deaths, o_victim_acc = as.integer(victims),
          o_ped_struck = as.integer(victims & ped_crash))]
OUT <- c("Deaths" = "o_deaths", "Pedestrian deaths" = "o_ped_deaths",
         "Accidents with victims" = "o_victim_acc", "Pedestrians struck, with victims" = "o_ped_struck")

days <- CJ(unit = unique(geo$unit), date = seq(as.IDate("2016-01-01"), as.IDate("2025-12-31"), by = "day"),
           bin = -2:0)
md <- days[, month(date) * 100L + mday(date)]
days[, window := fcase(md >= 408L & md <= 1024L, "win", md >= 1108L | md <= 307L, "off")]
days <- days[!is.na(window)]
days[, `:=`(sy = year(date), h0 = as.integer(bin == 0L))]
days[, x := h0 * as.integer(window == "win") * as.integer(sy >= 2023L)]

res <- rbindlist(lapply(names(OUT), function(o) {
  y <- ev[, .(y = sum(get(OUT[[o]]))), by = .(unit, date, bin)]
  p <- y[days, on = .(unit, date, bin)][is.na(y), y := 0]
  m <- fepois(y ~ x | unit^date + unit^h0^window + unit^h0^sy, data = p, cluster = ~unit, notes = FALSE)
  data.table(outcome = o, lp = 100 * coef(m)[["x"]], se = 100 * se(m)[["x"]], p = pvalue(m)[["x"]],
             hour0_pre_per_year = p[h0 == 1 & window == "win" & sy < 2023, sum(y)] / 7,
             n_obs = nobs(m))
}))

saveRDS(res, file.path(path_audit, "mexico_within_day.rds"))
options(width = 160)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
