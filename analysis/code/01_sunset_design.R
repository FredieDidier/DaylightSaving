# =============================================================================
# 01_sunset_design.R
#
# The sharp test. Abolition changes light at exactly one clock hour at each end
# of the day, and that hour differs by municipality and date:
#
#   evening: clock [sunset_std, sunset_std + 60 min) was daylight under DST
#            (the sun set at clock sunset_std + 60) and is dark without it.
#   morning: clock [sunrise_std, sunrise_std + 60 min) was dark under DST
#            and is light without it.
#
# sunset_std / sunrise_std are in local STANDARD time at the municipal seat
# (NOAA equations, analysis/code/00_utils.R). Every event is placed in a
# 60-minute bin relative to these times, using its recorded clock time. The
# prediction: in treated states, in the DST window, after 2019, events rise in
# evening bin 0, fall in morning bin 0, and neighbouring bins move less.
#
# Events with a trustworthy clock time of the incident:
#   - SIM deaths that occurred on the public road (LOCOCOR = 4): land transport
#     (V01-V89) and assault (X85-Y09). Deaths in hospital carry the hour of
#     death, not of the crash, and are excluded.
#   - PRF accidents with deaths (weighted by deaths) and with any victim;
#     municipality matched by name within UF. Accidents without victims are
#     never used (e-DAT break, see horario_verao/VIABILIDADE.md).
#
# Writes the event-level file that the later scripts read (with the
# pedestrian / other split used by 12_mechanism.R) and the bin-by-bin Poisson
# triple differences (figure: 27_figures.R).
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
})

SEASONS <- season_range()
days <- make_days(SEASONS)
geo  <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output",
                                             "muni_geo.parquet")))

# Sanity check of the solar equations: Sao Paulo, 21 Dec, standard time,
# sunset ~18:50 and sunrise ~05:15.
chk <- sun_times(as.Date("2018-12-21"), -23.55, -46.63, -3)
stopifnot(abs(chk$sunset - (18 * 60 + 50)) < 10, abs(chk$sunrise - (5 * 60 + 15)) < 10)

# ── Events ──────────────────────────────────────────────────────────────────
yrs <- (min(SEASONS)):(max(SEASONS) + 1L)
sim <- rbindlist(lapply(yrs, function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "LOCOCOR",
                                            "CAUSABAS", "preliminary")))))
stopifnot(!any(sim$preliminary))
sim <- sim[LOCOCOR == "4"]
sim[, outcome := fcase(CAUSABAS >= "V01" & CAUSABAS < "V90", "SIM transport deaths, on road",
                       CAUSABAS >= "X85" & CAUSABAS < "Y10", "SIM assault deaths, on road")]
# Mechanism split of on-road transport deaths (12_mechanism.R): pedestrians
# (V01-V09) against everyone else (V10-V89). Extra rows; the pooled outcome
# above is unchanged.
sim[, mech := fcase(CAUSABAS >= "V01" & CAUSABAS < "V10", "SIM pedestrian deaths, on road",
                    CAUSABAS >= "V10" & CAUSABAS < "V90", "SIM non-pedestrian deaths, on road")]
sim <- rbind(sim[!is.na(outcome)], sim[!is.na(mech)][, outcome := mech])
ev_sim <- sim[!is.na(outcome), .(code6 = as.integer(CODMUNOCOR),
                                 date = as.IDate(DTOBITO, format = "%d%m%Y"),
                                 cmin = clock_min(HORAOBITO), outcome, w = 1L)]
rm(sim); gc()

prf <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "prf", "output",
                                            "prf_accidents.parquet")))
prf <- prf_code6(prf, geo)   # municipality by name (00_utils.R)
prf_match <- prf[, round(100 * mean(!is.na(code6)), 1)]
prf[, cmin := 60L * hour + minute]
prf[, ped := grepl("^Atropelamento de (pessoa|pedestre)", tipo_acidente, ignore.case = TRUE)]
ev_prf <- rbind(
  prf[mortos > 0, .(code6, date, cmin, outcome = "PRF deaths", w = mortos)],
  prf[mortos > 0 | feridos > 0, .(code6, date, cmin, outcome = "PRF injury accidents", w = 1L)],
  # Mechanism split (12_mechanism.R): pedestrian struck against the rest.
  prf[ped & (mortos > 0 | feridos > 0), .(code6, date, cmin, outcome = "PRF pedestrian injury accidents", w = 1L)],
  prf[!ped & (mortos > 0 | feridos > 0), .(code6, date, cmin, outcome = "PRF non-pedestrian injury accidents", w = 1L)],
  prf[ped & mortos > 0, .(code6, date, cmin, outcome = "PRF pedestrian deaths", w = mortos)],
  prf[!ped & mortos > 0, .(code6, date, cmin, outcome = "PRF non-pedestrian deaths", w = mortos)])
rm(prf); gc()

ev <- rbind(ev_sim, ev_prf)
ev <- geo[, .(code6, uf, lat, lon, std_offset_h)][ev, on = "code6", nomatch = 0]
ev <- ev[uf %in% c(TREATED, CONTROL) & !is.na(cmin) & !is.na(date)]
st <- ev[, sun_times(date, lat, lon, std_offset_h)]
ev[, `:=`(bin_set  = floor((cmin - st$sunset)  / 60),
          bin_rise = floor((cmin - st$sunrise) / 60))]
write_parquet(ev[, .(uf, code6, date, cmin, outcome, w, bin_set, bin_rise)], EVENTS_FILE)

# ── Bin-by-bin triple differences ───────────────────────────────────────────
OUTCOMES <- c(TRAFFIC, "SIM assault deaths, on road")
spec <- rbind(data.table(side = "set", bin = -3:2), data.table(side = "rise", bin = -2:2))
grid <- CJ(outcome = OUTCOMES, k = seq_len(nrow(spec)), sorted = FALSE)
grid <- cbind(grid, spec[grid$k])

res <- grid[, {
  p <- make_panel(ev, days, .BY$outcome, .BY$bin, .BY$side)
  m <- fepois(as.formula(paste("y ~ twp", FE)), data = p, cluster = ~uf)
  # nobs: state-days left after fepois drops fixed-effect groups whose counts
  # are all zero (they carry no information on twp); n_rows: the full panel.
  .(coef = coef(m)[["twp"]], se = se(m)[["twp"]], n_events = p[, sum(y)],
    n_treated_win_pre = p[tw == 1 & post == 0, sum(y)],
    nobs = nobs(m), n_rows = nrow(p))
}, by = .(outcome, side, bin)]
res[, `:=`(pct = 100 * (exp(coef) - 1), p = 2 * pnorm(-abs(coef / se)))]
res[, side := fifelse(side == "set", "evening (rel. to sunset)", "morning (rel. to sunrise)")]

# Figure: drawn by 27_figures.R from the cache saved below.

saveRDS(list(results = res, prf_match_pct = prf_match, seasons = SEASONS),
        file.path(path_audit, "sunset_design.rds"))
options(width = 160)
cat("Seasons:", min(SEASONS), "-", max(SEASONS), "| PRF municipality match:", prf_match, "%\n")
print(res[, .(outcome, side, bin, pct = round(pct, 1), se_lp = round(100 * se, 1),
              p = round(p, 3), n_events, n_treated_win_pre)])
