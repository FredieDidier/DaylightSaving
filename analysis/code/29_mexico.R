# =============================================================================
# 29_mexico.R
#
# Replication in Mexico. The Ley de los Husos Horarios (DOF 28/10/2022, text in
# horario_verao/fontes_legais/MX_LHHEUM_2022.txt) ended DST on 30/10/2022
# everywhere except the northern border: Baja California and 22 listed
# municipalities of Coahuila, Nuevo Leon and Tamaulipas keep a seasonal
# schedule on US dates (second Sunday of March to first Sunday of November),
# as they had since 2010. Sonora (no DST since 1999) and Quintana Roo (UTC-5,
# no DST since 1 February 2015) never changed. Chihuahua is dropped: the same
# law moved it from the Pacific to the Central zone (UTC-7 to UTC-6), and a
# reform of 29/11/2022 split its border municipalities again.
#
# Before 2023, the rest of the country had DST from the first Sunday of April
# to the last Sunday of October (Decree of 1 March 2002).
#
# Design, as in 02 for Brazil:
#   unit     state x regime: the interior of each state (treated: lost DST),
#            and the control units Sonora, Quintana Roo, Baja California, and
#            the border municipalities of Coahuila, Nuevo Leon, Tamaulipas.
#   window   8 April - 24 October: under DST in every year 2016-2022 for the
#            treated units.
#   off      8 November - 7 March: no DST anywhere, US dates included.
#   season   the calendar year; 2016-2022 before, 2023-2025 after.
#   hour 0   clock [sunset_std, sunset_std + 60 min) at the municipal seat
#            (build/10_mexico_geo.R), standard offsets by zone: Centro -6,
#            Pacifico -7, Noroeste -8, Sureste -5.
#   model    y ~ treated x window x post | unit^window + unit^sy + date,
#            standard errors clustered by unit; wild cluster bootstrap on the
#            linear analogue and permutation of which units are treated.
# Outcomes (ATUS, build/11_mexico_atus.R; non-federal roads, deaths at the
# scene): deaths, pedestrian deaths, accidents with victims, pedestrians
# struck with victims.
#
# Clock: ATUS records legal (clock) time. Test, as for the PNCT in 16: in the
# treated interior, the hourly profile of accidents in the summer window under
# DST (2016-2022) matches the profile without DST (2023-2025) at the same clock
# hour (squared distance 0.66) far better than shifted by one hour (6.86 and
# 10.03); people follow the clock, and the record follows it too. Recomputed
# below and saved as clock_check.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(fwildclusterboot)
})

N_PERM <- as.integer(Sys.getenv("DS_PERM", unset = "999"))
set.seed(20221030)                       # last DST night in Mexico
dqrng::dqset.seed(20221030)

MX <- file.path(DROPBOX_ROOT, "build", "mexico", "output")
geo <- as.data.table(read_parquet(file.path(MX, "mx_muni_geo.parquet")))
acc <- as.data.table(read_parquet(file.path(MX, "atus_accidents.parquet")))
acc[, date := as.IDate(date)]

# ── Regimes ─────────────────────────────────────────────────────────────────
# State codes (INEGI): 02 Baja California, 03 BCS, 05 Coahuila, 08 Chihuahua,
# 18 Nayarit, 19 Nuevo Leon, 23 Quintana Roo, 25 Sinaloa, 26 Sonora,
# 28 Tamaulipas. Border municipalities as listed in Art. 5, fraction I.
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

geo <- geo[cve_ent != "08"]                                  # Chihuahua out
geo[, std_offset_h := fcase(cve_ent == "02", -8, cve_ent == "23", -5,
                            cve_ent %in% c("03", "25", "26"), -7,
                            cve_ent == "18" & nm != norm("Bahia de Banderas"), -7,
                            default = -6)]
geo[, unit := fcase(cve_ent %in% c("02", "23", "26"), cve_ent,
                    border, paste0(cve_ent, "b"), default = cve_ent)]
geo[, treated := as.integer(!(cve_ent %in% c("02", "23", "26") | border))]
# Two seats have no coordinates in the INEGI service (Mocorito and Sinaloa,
# both in Sinaloa, treated); their accidents are dropped and counted.
no_xy <- geo[is.na(lat)]
cat("Municipalities without coordinates:", nrow(no_xy), "-",
    acc[no_xy, on = .(cve_ent, cve_mun), nomatch = 0, .N], "accidents dropped\n")
stopifnot(nrow(no_xy) <= 2L)
geo <- geo[!is.na(lat)]

# ── Events ──────────────────────────────────────────────────────────────────
ev <- geo[, .(cve_ent, cve_mun, unit, lat, lon, std_offset_h)][acc, on = .(cve_ent, cve_mun), nomatch = 0]
cat("Accidents matched to a municipality:", round(100 * nrow(ev) / acc[cve_ent != "08", .N], 2), "%\n")
ev <- ev[!is.na(cmin)]
st <- ev[, sun_times(date, lat, lon, std_offset_h)]
ev[, `:=`(bin_set = floor((cmin - st$sunset) / 60), bin_rise = floor((cmin - st$sunrise) / 60))]

ev[, `:=`(o_deaths = deaths, o_ped_deaths = ped_deaths, o_victim_acc = as.integer(victims),
          o_ped_struck = as.integer(victims & ped_crash))]
OUT <- c("Deaths" = "o_deaths", "Pedestrian deaths" = "o_ped_deaths",
         "Accidents with victims" = "o_victim_acc", "Pedestrians struck, with victims" = "o_ped_struck")

# ── Clock check ─────────────────────────────────────────────────────────────
ck <- acc[!cve_ent %in% c("02", "08", "23", "26") & !is.na(cmin)]
ck[, `:=`(md = month(date) * 100L + mday(date), h = cmin %/% 60L, y = year(date))]
ck <- ck[md >= 408L & md <= 1024L & y >= 2016L, .N, by = .(per = fifelse(y <= 2022L, "pre", "post"), h)]
ck[, s := 100 * N / sum(N), by = per]
pre_s <- ck[per == "pre"][order(h)]$s; post_s <- ck[per == "post"][order(h)]$s
clock_check <- data.table(lag = -1:1, sq_dist = sapply(-1:1, function(k) sum((pre_s[6:22] - post_s[(6:22) + k])^2)))
print(clock_check)
stopifnot(clock_check[which.min(sq_dist), lag] == 0L)

# ── Days ────────────────────────────────────────────────────────────────────
units <- unique(geo[, .(unit, treated)])
days <- CJ(unit = units$unit, date = seq(as.IDate("2016-01-01"), as.IDate("2025-12-31"), by = "day"))
md <- days[, month(date) * 100L + mday(date)]
days[, window := fcase(md >= 408L & md <= 1024L, "win", md >= 1108L | md <= 307L, "off")]
days <- days[!is.na(window)]
days[, `:=`(sy = year(date))]
days <- units[days, on = "unit"]
days[, `:=`(win = as.integer(window == "win"), post = as.integer(sy >= 2023L))]
days[, `:=`(tw = treated * win)][, twp := tw * post]

panel <- function(o, b, side = "set") {
  col <- if (side == "set") "bin_set" else "bin_rise"
  y <- ev[ev[[col]] == b, .(y = sum(get(OUT[[o]]))), by = .(unit, date)]
  p <- y[days, on = .(unit, date)][is.na(y), y := 0]
  p[]
}
FEm <- "| unit^window + unit^sy + date"
fit <- function(p) fepois(as.formula(paste("y ~ twp", FEm)), data = p, cluster = ~unit, notes = FALSE)

# ── By hour ─────────────────────────────────────────────────────────────────
hours <- rbind(data.table(side = "set", bin = -3:2), data.table(side = "rise", bin = -2:2))
res <- rbindlist(lapply(names(OUT), function(o) rbindlist(lapply(seq_len(nrow(hours)), function(i) {
  p <- panel(o, hours$bin[i], hours$side[i])
  m <- fit(p)
  data.table(outcome = o, side = hours$side[i], bin = hours$bin[i],
             lp = 100 * coef(m)[["twp"]], se = 100 * se(m)[["twp"]], p = pvalue(m)[["twp"]],
             pre_per_year = p[tw == 1 & post == 0, sum(y)] / 7)
}))))

# ── Inference for evening hour 0 ────────────────────────────────────────────
U <- units$unit; NT <- sum(units$treated)
FAKES <- replicate(N_PERM, sample(U, NT), simplify = FALSE)
inf <- rbindlist(lapply(names(OUT), function(o) {
  p <- panel(o, 0L, "set")
  b <- coef(fit(p))[["twp"]]
  dm <- as.data.table(demean(p[, .(y, twp)], f = p[, .(uw = paste(unit, window),
                                                       us = paste(unit, sy), date)]))
  dm[, unit := p$unit]
  wb <- boottest(lm(y ~ twp, data = dm), param = "twp", clustid = "unit", B = 9999, type = "webb")
  perm <- vapply(FAKES, function(f) {
    p[, fk := as.integer(unit %in% f) * win * post]
    coef(fepois(as.formula(paste("y ~ fk", FEm)), data = p, notes = FALSE))[["fk"]]
  }, numeric(1))
  data.table(outcome = o, lp = 100 * b, wcr_p = pval(wb), perm_p = perm_pvalue(perm, b))
}))

# ── Event study, evening hour 0 (reference 2022) ────────────────────────────
es <- rbindlist(lapply(names(OUT), function(o) {
  p <- panel(o, 0L, "set")
  m <- fepois(as.formula(paste("y ~ i(sy, tw, ref = 2022)", FEm)), data = p, cluster = ~unit, notes = FALSE)
  ct <- as.data.table(coeftable(m), keep.rownames = "term")
  rbind(ct[, .(outcome = o, sy = as.integer(sub("sy::(\\d+):tw", "\\1", term)), coef = Estimate,
               se = `Std. Error`)], data.table(outcome = o, sy = 2022L, coef = 0, se = 0))
}))

saveRDS(list(by_hour = res, inference = inf, event_study = es, clock_check = clock_check,
             units = geo[, .N, by = .(unit, treated)], n_perm = N_PERM),
        file.path(path_audit, "mexico.rds"))
options(width = 170)
print(geo[, .N, by = .(unit, treated)][order(treated, unit)])
print(res[bin == 0L | (side == "set" & bin == -1L), lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])
print(inf)
