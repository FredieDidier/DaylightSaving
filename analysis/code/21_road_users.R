# =============================================================================
# 21_road_users.R
#
# Who dies in the evening hour that turned dark: on-road SIM transport deaths
# (V01-V89, LOCOCOR = 4, as in 01) split by
#   (a) road user, from the ICD-10 block of the underlying cause:
#       pedestrian V01-V09, cyclist V10-V19, motorcyclist V20-V29,
#       car or light-vehicle occupant V40-V59, other V30-V39 and V60-V89;
#   (b) pedestrians by age (0-14, 15-64, 65+) and sex;
#   (c) the day: working days against weekends and national holidays, and
#       the weekends and holidays again without Carnival and the year-end
#       holidays (holiday_days, 00_utils.R), whose travel is least like the
#       rest of the summer;
#   (d) every road user by sex and by age (0-14, 15-29, 30-44, 45-59, 60+),
#       in road deaths and in federal highway deaths. On federal highways the
#       sex and age of each person dead at the scene come from the PRF person
#       files (build/13), matched to the accident by its id.
# Also the make-up of "other": the ICD-10 blocks of the deaths it holds.
# Same Poisson triple difference as 01 for clock [sunset_std, + 60 min).
#
# Events are rebuilt from the raw SIM and PRF files because the event file of
# 01 does not carry age or sex. The rebuild must give back the 01 counts.
#
# On federal highways the age of 11-12% of the dead is unknown up to 2016 and
# of 5-6% from 2017 (build/13). The change is national and falls between two
# seasons, so the state-by-season effects absorb it as long as it is the same
# in the summer window and the off-season; the deaths of unknown age are
# estimated as a group of their own to show it.
#
# SIM IDADE: first digit is the unit (4 = years, 5 = 100 + the two digits;
# 0-3 = minutes, hours, days, months, i.e. under one year); 999 / missing is
# unknown. SEXO: 1 male, 2 female, 0 / 9 unknown.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
geo  <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output",
                                             "muni_geo.parquet")))

sim <- rbindlist(lapply((min(SEASONS)):(max(SEASONS) + 1L), function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "LOCOCOR",
                                            "CAUSABAS", "IDADE", "SEXO", "preliminary")))))
stopifnot(!any(sim$preliminary))
sim <- sim[LOCOCOR == "4" & CAUSABAS >= "V01" & CAUSABAS < "V90"]
sim[, `:=`(code6 = as.integer(CODMUNOCOR), date = as.IDate(DTOBITO, format = "%d%m%Y"),
           cmin = clock_min(HORAOBITO))]
sim <- geo[, .(code6, uf, lat, lon, std_offset_h)][sim, on = "code6", nomatch = 0]
sim <- sim[uf %in% c(TREATED, CONTROL) & !is.na(cmin) & !is.na(date)]
sim[, bin_set := floor((cmin - sun_times(date, lat, lon, std_offset_h)$sunset) / 60)]

# Guard: same events as the 01 event file.
ev02 <- as.data.table(read_parquet(EVENTS_FILE))[outcome == "SIM transport deaths, on road"]
stopifnot(nrow(ev02) == nrow(sim), sum(ev02$bin_set == 0) == sum(sim$bin_set == 0))

sim[, blk := as.integer(substr(CAUSABAS, 2, 3))]
sim[, user := fcase(blk <= 9L, "pedestrian", blk <= 19L, "cyclist", blk <= 29L, "motorcyclist",
                    blk >= 40L & blk <= 59L, "car or light vehicle", default = "other")]
unit <- substr(sim$IDADE, 1, 1); val <- suppressWarnings(as.integer(substr(sim$IDADE, 2, 3)))
sim[, age := fcase(unit == "4", val, unit == "5", 100L + val, unit %in% c("0", "1", "2", "3"), 0L,
                   default = NA_integer_)]
sim[, age_group := fcase(age < 15L, "0-14", age < 65L, "15-64", age >= 65L, "65+")]
sim[, sex := fcase(SEXO == "1", "male", SEXO == "2", "female")]
AGE5 <- c("0-14", "15-29", "30-44", "45-59", "60+")
age5 <- function(a) fcase(a < 15L, "0-14", a < 30L, "15-29", a < 45L, "30-44", a < 60L, "45-59",
                          a >= 60L, "60+", default = "unknown")
sim[, `:=`(age5 = age5(age), w = 1L)]

# Federal highway deaths, one row per accident and sex-by-age cell of its dead.
prf <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "prf", "output", "prf_accidents.parquet"),
                                  col_select = c("year_file", "id", "date", "uf", "municipio",
                                                 "hour", "minute", "mortos")))[mortos > 0]
prf <- prf_code6(prf, geo)
per <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "prf", "output", "prf_persons.parquet"),
                                  col_select = c("year_file", "id", "state", "age", "sex")))[state == "dead"]
per <- per[, .(w = .N), by = .(year_file, id, sex, age5 = age5(age))]
prf <- per[prf[, .(year_file, id, code6, date, cmin = 60L * hour + minute)], on = .(year_file, id), nomatch = 0]
prf <- geo[, .(code6, uf, lat, lon, std_offset_h)][prf, on = "code6", nomatch = 0]
prf <- prf[uf %in% c(TREATED, CONTROL) & !is.na(cmin) & !is.na(date)]
prf[, bin_set := floor((cmin - sun_times(date, lat, lon, std_offset_h)$sunset) / 60)]
# Guard: the dead add up to the PRF deaths of the 01 event file, bin by bin
# (the person and accident files disagree on one accident in the sample years).
ev_prf <- as.data.table(read_parquet(EVENTS_FILE))[outcome == "PRF deaths", .(w01 = sum(w)), by = bin_set]
gp <- prf[, .(w = sum(w)), by = bin_set][ev_prf, on = "bin_set"]
stopifnot(gp[, all(abs(w - w01) <= 1)])

# National holidays inside or next to the summer window and the off-season:
# fixed dates plus Carnival Monday and Tuesday and Good Friday (easter_date,
# 00_utils.R). State and municipal holidays are not coded.
yrs <- (min(SEASONS)):(max(SEASONS) + 1L)
fixed <- c("01-01", "04-21", "05-01", "09-07", "10-12", "11-02", "11-15", "12-25")
# 20 November (Black Consciousness Day) is a national holiday from 2024 on
# (Law 14,759/2023) and falls in the 2024/25 summer window.
hol <- c(as.IDate(unlist(lapply(yrs, function(y) sprintf("%d-%s", y, fixed)))),
         as.IDate(sprintf("%d-11-20", yrs[yrs >= 2024L])),
         do.call(c, lapply(yrs, function(y) easter_date(y) + c(-48L, -47L, -2L))))
stopifnot(easter_date(2019L) == as.IDate("2019-04-21"), easter_date(2024L) == as.IDate("2024-03-31"))
days[, daytype := fifelse(wday(date) %in% c(1L, 7L) | date %in% hol, "weekend or holiday", "working day")]

est_ev <- function(e, dd = days) {
  y <- e[bin_set == 0L, .(y = sum(w)), by = .(uf, date)]
  p <- y[dd, on = .(uf, date)][is.na(y), y := 0]
  # A cell too small to identify twp (collinear with the fixed effects) is
  # kept with its counts and no estimate.
  m <- tryCatch(fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf, notes = FALSE),
                error = function(e) NULL)
  data.table(lp = if (is.null(m)) NA_real_ else 100 * coef(m)[["twp"]],
             se = if (is.null(m)) NA_real_ else 100 * se(m)[["twp"]],
             p  = if (is.null(m)) NA_real_ else pvalue(m)[["twp"]],
             pre_per_season = p[tw == 1 & post == 0, sum(y)] / sum(SEASONS <= LAST_PRE),
             post_per_season = p[tw == 1 & post == 1, sum(y)] / sum(SEASONS > LAST_PRE))
}
est <- function(sel, dd = days) est_ev(sim[sel], dd)

all_ <- rep(TRUE, nrow(sim))
res <- rbind(
  data.table(split = "all", group = "all", est(all_)),
  rbindlist(lapply(c("pedestrian", "cyclist", "motorcyclist", "car or light vehicle", "other"),
                   function(g) data.table(split = "road user", group = g, est(sim$user == g)))),
  rbindlist(lapply(c("0-14", "15-64", "65+"), function(g)
    data.table(split = "pedestrian age", group = g,
               est(sim$user == "pedestrian" & sim$age_group %in% g)))),
  rbindlist(lapply(c("male", "female"), function(g)
    data.table(split = "pedestrian sex", group = g, est(sim$user == "pedestrian" & sim$sex %in% g)))),
  rbindlist(lapply(c("working day", "weekend or holiday"), function(g)
    data.table(split = "day", group = g, est(all_, days[daytype == g])))),
  rbindlist(lapply(c("working day", "weekend or holiday"), function(g)
    data.table(split = "day, pedestrians", group = g, est(sim$user == "pedestrian", days[daytype == g])))),
  data.table(split = "day", group = "weekend or holiday, without Carnival and year-end",
             est(all_, days[daytype == "weekend or holiday" & !date %in% holiday_days(yrs)])))
res[, outcome := "SIM transport deaths, on road"]

# (d) Sex and age of every road user, in both registers.
by_person <- function(e, o) rbind(
  data.table(outcome = o, split = "all", group = "all", est_ev(e)),
  rbindlist(lapply(c("male", "female"), function(g)
    data.table(outcome = o, split = "sex", group = g, est_ev(e[sex %in% g])))),
  rbindlist(lapply(c(AGE5, "unknown"), function(g)
    data.table(outcome = o, split = "age", group = g, est_ev(e[age5 == g])))))
res <- rbind(res, by_person(sim, "SIM transport deaths, on road")[split != "all"],
             by_person(prf, "PRF deaths"))
setcolorder(res, "outcome")

# A cell with ~2 events per summer gives a degenerate Poisson estimate (child
# pedestrians: 2.3 before abolition, 1.0 after, estimate -1235 log points).
# Groups below 5 treated summer events per season before abolition are kept
# in the cache but flagged, and no exhibit prints them.
res[, estimable := pre_per_season >= 5]

other_blocks <- sim[user == "other" & bin_set == 0L,
                    .(n = .N), by = .(block = fcase(blk <= 39L, "V30-V39 three-wheeled vehicle",
                                                    blk <= 69L, "V60-V69 heavy transport vehicle",
                                                    blk <= 79L, "V70-V79 bus",
                                                    blk <= 86L, "V80-V86 other specified",
                                                    blk <= 88L, "V87-V88 traffic, vehicle unspecified",
                                                    default = "V89 vehicle and traffic unspecified"))]
other_blocks[, pct := 100 * n / sum(n)]
coverage <- sim[, .(n = .N, age_missing_pct = 100 * mean(is.na(age)), sex_missing_pct = 100 * mean(is.na(sex))),
                by = user]
coverage_prf <- prf[, .(n = sum(w), age_missing_pct = 100 * sum(w[age5 == "unknown"]) / sum(w),
                        sex_missing_pct = 100 * sum(w[is.na(sex)]) / sum(w)), by = .(before_2017 = year(date) < 2017L)]
saveRDS(list(results = res, coverage = coverage, coverage_prf = coverage_prf, other_blocks = other_blocks),
        file.path(path_audit, "road_users.rds"))
print(other_blocks[order(-n)])
options(width = 160)
print(coverage)
print(coverage_prf)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
