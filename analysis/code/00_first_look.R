# =============================================================================
# 00_first_look.R
#
# First look at the data: does the clock change show up where it must, and is
# there anything in the outcomes worth a paper?
#
# Groups (fixed for the whole window, so the comparison is clean):
#   treated  RS SC PR SP RJ ES MG GO MT MS DF  (DST in every season 2008/09-2018/19)
#   control  N and NE except BA, TO (one DST season each) and AC, AM (time-zone
#            changes in 2008 and 2013)
#
# Windows within each season (Jul-Jun):
#   win  Nov 15 - Feb 14: clocks were advanced on every one of these days in
#        every pre-abolition season (2018/19 started Nov 4; the earliest end
#        was Feb 15, 2009)
#   off  Apr 1 - Aug 31: never DST
# Periods: pre = 2009/10-2018/19, post = 2019/20-2023/24 (consolidated SIM and
# SINASC end in 2024).
#
# Statistic, by clock hour h:
#   D(h) = [share_T,win(h) - share_T,off(h)] - [share_C,win(h) - share_C,off(h)]
# computed separately pre and post. If an outcome follows the sun and the clock
# moved one hour, D(h) shows the signature f(h-1) - f(h) before 2019 and goes
# flat after. An outcome scheduled by the clock should be flat in both.
#
# Writes figures to analysis/output/graphs/ and a numbers file to the Dropbox
# audit folder. Reads WorldCupHealth files; never writes there.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))     # figure style
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(ggplot2)
})

TREATED <- c("RS", "SC", "PR", "SP", "RJ", "ES", "MG", "GO", "MT", "MS", "DF")
CONTROL <- c("RO", "RR", "PA", "AP", "MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE")
UF_CODE <- c(RO = 11, AC = 12, AM = 13, RR = 14, PA = 15, AP = 16, TO = 17,
             MA = 21, PI = 22, CE = 23, RN = 24, PB = 25, PE = 26, AL = 27,
             SE = 28, BA = 29, MG = 31, ES = 32, RJ = 33, SP = 35, PR = 41,
             SC = 42, RS = 43, MS = 50, MT = 51, GO = 52, DF = 53)
code_to_uf <- setNames(names(UF_CODE), UF_CODE)

# Assign group, season, window and period from a date and a 2-digit UF code.
tag <- function(d, date, ufcode) {
  d[, uf := code_to_uf[as.character(ufcode)]]
  d[, group := fcase(uf %in% TREATED, "treated", uf %in% CONTROL, "control")]
  d[, sy := year(date) - (month(date) < 7L)]           # season start year
  md <- month(date) * 100L + mday(date)
  d[, window := fcase(md >= 1115L | md <= 214L, "win",
                      md >= 401L & md <= 831L, "off")]
  d[, period := fcase(sy %between% c(2009L, 2018L), "pre",
                      sy %between% c(2019L, 2023L), "post")]
  d[!is.na(group) & !is.na(window) & !is.na(period)]
}

parse_hour <- function(x) {
  h <- suppressWarnings(as.integer(substr(x, 1, 2)))
  m <- suppressWarnings(as.integer(substr(x, 3, 4)))
  fifelse(nchar(x) == 4L & h %between% c(0L, 23L) & m %between% c(0L, 59L),
          h, NA_integer_)
}

# ── 1. Load ─────────────────────────────────────────────────────────────────
years <- 2009:2024
sim <- rbindlist(lapply(years, function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR",
                                            "CAUSABAS", "preliminary")))))
sim <- sim[preliminary == FALSE]
sim[, date := as.IDate(DTOBITO, format = "%d%m%Y")]
sim[, hour := parse_hour(HORAOBITO)]
sim <- tag(sim, sim$date, substr(sim$CODMUNOCOR, 1, 2))
sim[, cause := fcase(CAUSABAS >= "V01" & CAUSABAS < "V90", "traffic",
                     CAUSABAS >= "X85" & CAUSABAS < "Y10", "assault",
                     CAUSABAS >= "I21" & CAUSABAS < "I23", "ami",
                     default = "other")]
sim[, c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "preliminary") := NULL]

sinasc <- rbindlist(lapply(years, function(y)
  as.data.table(read_parquet(file.path(path_wch_sinasc, sprintf("sinasc_lean_%d.parquet", y)),
                             col_select = c("DTNASC", "HORANASC", "CODMUNNASC",
                                            "PARTO", "preliminary")))))
sinasc <- sinasc[preliminary == FALSE]
sinasc[, date := as.IDate(DTNASC, format = "%d%m%Y")]
sinasc[, hour := parse_hour(HORANASC)]
sinasc <- tag(sinasc, sinasc$date, substr(sinasc$CODMUNNASC, 1, 2))
sinasc[, cause := fcase(PARTO == "1", "vaginal", PARTO == "2", "cesarean")]
sinasc <- sinasc[!is.na(cause)]
sinasc[, c("DTNASC", "HORANASC", "CODMUNNASC", "PARTO", "preliminary") := NULL]

# ── 2. Data quality: missing clock time ─────────────────────────────────────
miss <- rbind(
  sim[, .(source = "SIM", miss = mean(is.na(hour)), n = .N), by = .(sy, group)],
  sinasc[, .(source = "SINASC", miss = mean(is.na(hour)), n = .N), by = .(sy, group)])
setorder(miss, source, group, sy)

# ── 3. Triple-difference hourly profile ─────────────────────────────────────
profile <- function(d) {
  s <- d[!is.na(hour), .N, by = .(cause, group, window, period, hour)]
  s <- s[CJ(cause = unique(cause), group = unique(group), window = unique(window),
            period = unique(period), hour = 0:23),
         on = .(cause, group, window, period, hour)][is.na(N), N := 0L]
  s[, share := N / sum(N), by = .(cause, group, window, period)]
  w <- dcast(s, cause + period + hour ~ group + window, value.var = "share")
  w[, D := (treated_win - treated_off) - (control_win - control_off)]
  w[, n_tw := s[group == "treated" & window == "win", sum(N), by = .(cause, period)][
      .SD, on = .(cause, period), V1]]
  w
}
prof <- rbind(profile(sim[cause != "other"]), profile(sinasc))
prof[, period := factor(period, c("pre", "post"))]
prof[, cause := factor(cause, c("vaginal", "cesarean", "traffic", "assault", "ami"))]

# A one-number summary of the shift: correlation of D(h) with the pure
# one-hour-later signature built from the treated off-season profile.
sig <- prof[, .(hour, sig = shift(treated_off, 1L, type = "lag",
                                  fill = treated_off[24]) - treated_off),
            by = .(cause, period)]
prof <- sig[prof, on = .(cause, period, hour)]
summ <- prof[, .(corr_with_1h_shift = cor(D, sig),
                 sum_abs_D_pp = 100 * sum(abs(D)),
                 n_treated_win = n_tw[1]), by = .(cause, period)]
setorder(summ, cause, period)

# ── 4. Level contrast in the DST window (counts per day, triple difference) ─
lvl <- sim[cause %in% c("traffic", "assault", "ami"),
           .(n = .N), by = .(cause, group, window, period)]
ndays <- CJ(window = c("win", "off"), period = c("pre", "post"))
ndays[, days := fifelse(window == "win", 92, 153) *
        fifelse(period == "pre", 10, 5)]                       # approx. days
lvl <- ndays[lvl, on = .(window, period)]
lvl[, lpd := log(n / days)]
ddd <- dcast(lvl, cause ~ group + window + period, value.var = "lpd")
ddd[, ddd_logpts := 100 * (((treated_win_post - treated_off_post) -
                            (treated_win_pre  - treated_off_pre)) -
                           ((control_win_post - control_off_post) -
                            (control_win_pre  - control_off_pre)))]

# ── 5. Outputs ──────────────────────────────────────────────────────────────
CAUSE_LAB <- c(vaginal = "Vaginal births", cesarean = "Cesarean births",
               traffic = "Transport deaths", assault = "Assault deaths",
               ami = "Heart-attack deaths")
fig <- copy(prof)
fig[, cause := factor(CAUSE_LAB[as.character(cause)], levels = CAUSE_LAB)]
fig[, period := factor(fifelse(period == "pre", "With DST, 2009/10\u20132018/19",
                               "Without DST, 2019/20\u20132023/24"),
                       levels = c("With DST, 2009/10\u20132018/19", "Without DST, 2019/20\u20132023/24"))]
g <- ggplot(fig, aes(hour, 100 * D, colour = period, shape = period, linetype = period)) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_line(linewidth = 0.6) + geom_point(size = 1.4) +
  facet_wrap(~ cause, ncol = 2, scales = "free_y") +
  scale_x_continuous(breaks = seq(0, 18, 6), labels = hour_ampm, expand = expansion(add = 0.5)) +
  scale_y_continuous(labels = num_lab) +
  scale_colour_manual(values = setNames(c(PAL[["red"]], PAL[["blue"]]), levels(fig$period))) +
  scale_shape_manual(values = setNames(c(16, 17), levels(fig$period))) +
  scale_linetype_manual(values = setNames(c("solid", "22"), levels(fig$period))) +
  labs(x = "Clock hour", y = "Triple difference in hourly share (p.p.)") +
  theme_paper() +
  theme(legend.position = "inside", legend.position.inside = c(0.75, 0.13),
        legend.direction = "vertical", legend.background = element_blank())
save_fig(g, "fig00_first_look_hour_profile", height = 7)

saveRDS(list(missing_hour = miss, shift_summary = summ, ddd_levels = ddd, profile = prof),
        file.path(path_audit, "first_look_numbers.rds"))

options(width = 150)
cat("\n== Missing clock time, by season start year ==\n")
print(dcast(miss, sy ~ source + group, value.var = "miss")[, lapply(.SD, function(x)
  if (is.numeric(x) && max(x) <= 1) round(100 * x, 1) else x)])
cat("\n== Shift signature (corr of D(h) with a pure 1-hour-later shift) ==\n")
print(summ[, .(cause, period, corr = round(corr_with_1h_shift, 2),
               sum_abs_D_pp = round(sum_abs_D_pp, 1), n_treated_win)])
cat("\n== Level triple difference in the DST window, log points (post - pre) ==\n")
print(ddd[, .(cause, ddd_logpts = round(ddd_logpts, 1))])
