# =============================================================================
# 21_road_users.R
#
# Who dies in the evening hour that turned dark: on-road SIM transport deaths
# (V01-V89, LOCOCOR = 4, as in 01) split by
#   (a) road user, from the ICD-10 block of the underlying cause:
#       pedestrian V01-V09, cyclist V10-V19, motorcyclist V20-V29,
#       car or light-vehicle occupant V40-V59, other V30-V39 and V60-V89;
#   (b) pedestrians by age (0-14, 15-64, 65+) and sex;
#   (c) the day: working days against weekends and national holidays.
# Same Poisson triple difference as 01 for clock [sunset_std, + 60 min).
#
# Events are rebuilt from the raw SIM files because the event file of 01 does
# not carry age or sex. The rebuild must give back the 01 counts exactly.
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

blk <- as.integer(substr(sim$CAUSABAS, 2, 3))
sim[, user := fcase(blk <= 9L, "pedestrian", blk <= 19L, "cyclist", blk <= 29L, "motorcyclist",
                    blk >= 40L & blk <= 59L, "car or light vehicle", default = "other")]
unit <- substr(sim$IDADE, 1, 1); val <- suppressWarnings(as.integer(substr(sim$IDADE, 2, 3)))
sim[, age := fcase(unit == "4", val, unit == "5", 100L + val, unit %in% c("0", "1", "2", "3"), 0L,
                   default = NA_integer_)]
sim[, age_group := fcase(age < 15L, "0-14", age < 65L, "15-64", age >= 65L, "65+")]
sim[, sex := fcase(SEXO == "1", "male", SEXO == "2", "female")]

# National holidays inside or next to the summer window and the off-season:
# fixed dates plus Carnival Monday and Tuesday and Good Friday (Easter by the
# anonymous Gregorian algorithm). State and municipal holidays are not coded.
easter <- function(y) {
  a <- y %% 19; b <- y %/% 100; c <- y %% 100; d <- b %/% 4; e <- b %% 4
  f <- (b + 8) %/% 25; g <- (b - f + 1) %/% 3; h <- (19 * a + b - d - g + 15) %% 30
  i <- c %/% 4; k <- c %% 4; l <- (32 + 2 * e + 2 * i - h - k) %% 7
  m <- (a + 11 * h + 22 * l) %/% 451; mo <- (h + l - 7 * m + 114) %/% 31
  as.IDate(sprintf("%d-%02d-%02d", y, mo, ((h + l - 7 * m + 114) %% 31) + 1))
}
yrs <- (min(SEASONS)):(max(SEASONS) + 1L)
fixed <- c("01-01", "04-21", "05-01", "09-07", "10-12", "11-02", "11-15", "12-25")
# 20 November (Black Consciousness Day) is a national holiday from 2024 on
# (Law 14,759/2023) and falls in the 2024/25 summer window.
hol <- c(as.IDate(unlist(lapply(yrs, function(y) sprintf("%d-%s", y, fixed)))),
         as.IDate(sprintf("%d-11-20", yrs[yrs >= 2024L])),
         do.call(c, lapply(yrs, function(y) easter(y) + c(-48L, -47L, -2L))))
stopifnot(easter(2019L) == as.IDate("2019-04-21"), easter(2024L) == as.IDate("2024-03-31"))
days[, daytype := fifelse(wday(date) %in% c(1L, 7L) | date %in% hol, "weekend or holiday", "working day")]

est <- function(sel, dd = days) {
  y <- sim[sel & bin_set == 0L, .(y = .N), by = .(uf, date)]
  p <- y[dd, on = .(uf, date)][is.na(y), y := 0]
  m <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf, notes = FALSE)
  data.table(lp = 100 * coef(m)[["twp"]], se = 100 * se(m)[["twp"]], p = pvalue(m)[["twp"]],
             pre_per_season = p[tw == 1 & post == 0, sum(y)] / sum(SEASONS <= LAST_PRE),
             post_per_season = p[tw == 1 & post == 1, sum(y)] / sum(SEASONS > LAST_PRE))
}

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
    data.table(split = "day, pedestrians", group = g, est(sim$user == "pedestrian", days[daytype == g])))))

# A cell with ~2 events per summer gives a degenerate Poisson estimate (child
# pedestrians: 2.3 before abolition, 1.0 after, estimate -1235 log points).
# Groups below 5 treated summer events per season before abolition are kept
# in the cache but flagged, and no exhibit prints them.
res[, estimable := pre_per_season >= 5]

coverage <- sim[, .(n = .N, age_missing_pct = 100 * mean(is.na(age)), sex_missing_pct = 100 * mean(is.na(sex))),
                by = user]
saveRDS(list(results = res, coverage = coverage), file.path(path_audit, "road_users.rds"))
options(width = 160)
print(coverage)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
