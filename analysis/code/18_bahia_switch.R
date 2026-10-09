# =============================================================================
# 18_bahia_switch.R
#
# Appendix check of sign: Bahia had DST in one season only inside the sample,
# 2011/12 (Decree 7,584/2011). That summer the evening light-switched hour
# (clock [sunset_std, sunset_std + 60)) was daylight in BA and dark in every
# other BA summer; the morning hour [sunrise_std, sunrise_std + 60) was the
# reverse. If darkness raises crashes, BA's evening hour 0 should be LOW in
# 2011/12 and its morning hour 0 HIGH, relative to the other BA seasons and to
# the 12 control states.
#
# One treated state in one season: cluster standard errors mean nothing here.
# Inference is a placebo in time. For every season s, fit
#   y[u,d] ~ ba x win x 1[sy = s] | uf^window + uf^sy + date
# on BA plus the 12 control states, all seasons 2008/09-2023/24, and rank the
# 2011/12 coefficient among the 16 (one real, 15 placebo seasons). This is a
# check of sign, not an estimate of the paper.
#
# First stage: share of PRF accidents in BA's evening hour 0 recorded by the
# officer as dusk or night, by season.
#
# BA is outside the analysis groups, so the event file of 02 has no BA rows;
# BA events are built here exactly as 02 builds the others (on-road SIM
# deaths V01-V89 with LOCOCOR = 4; PRF accidents with victims and deaths,
# municipality matched by name plus build/manual/prf_municipio_alias.csv).
# Control-state events come from the 02 event file.
# TO (DST in 2012/13 only) is left out: 3-8 on-road deaths per summer in hour 0.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
})

SEASONS <- season_range()
BA_SEASON <- 2011L
geo <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output",
                                            "muni_geo.parquet")))

# ── BA events, as in 02_sunset_design.R ─────────────────────────────────────
sim <- rbindlist(lapply((min(SEASONS)):(max(SEASONS) + 1L), function(y) {
  s <- as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                                  col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR",
                                                 "LOCOCOR", "CAUSABAS", "preliminary")))
  s[LOCOCOR == "4" & substr(CODMUNOCOR, 1, 2) == "29" & CAUSABAS >= "V01" & CAUSABAS < "V90"]
}))
stopifnot(!any(sim$preliminary))
ev_sim <- sim[, .(code6 = as.integer(CODMUNOCOR), date = as.IDate(DTOBITO, format = "%d%m%Y"),
                  cmin = clock_min(HORAOBITO), outcome = "SIM transport deaths, on road", w = 1L,
                  fase_dia = NA_character_)]

prf <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "prf", "output",
                                            "prf_accidents.parquet")))[uf == "BA"]
norm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
geo[, key := paste(uf, norm(name))]
alias <- fread(file.path(path_manual, "prf_municipio_alias.csv"), encoding = "UTF-8")
alias <- alias[, .(key = paste(uf, norm(municipio_prf)), code6)]
keys <- rbind(unique(geo[, .(key, code6)], by = "key"), alias[!key %in% geo$key])
prf[, key := paste(uf, norm(municipio))]
prf <- keys[prf, on = "key"]
prf[, cmin := 60L * hour + minute]
ev_prf <- rbind(
  prf[mortos > 0, .(code6, date, cmin, outcome = "PRF deaths", w = mortos, fase_dia)],
  prf[mortos > 0 | feridos > 0, .(code6, date, cmin, outcome = "PRF injury accidents", w = 1L, fase_dia)])

ev_ba <- geo[uf == "BA", .(code6, uf, lat, lon, std_offset_h)][rbind(ev_sim, ev_prf),
                                                               on = "code6", nomatch = 0]
ev_ba <- ev_ba[!is.na(cmin) & !is.na(date)]
st <- ev_ba[, sun_times(date, lat, lon, std_offset_h)]
ev_ba[, `:=`(bin_set = floor((cmin - st$sunset) / 60), bin_rise = floor((cmin - st$sunrise) / 60))]

ev <- rbind(as.data.table(read_parquet(EVENTS_FILE))[uf %in% CONTROL & outcome %in% TRAFFIC],
            ev_ba[, .(uf, code6, date, cmin, outcome, w, bin_set, bin_rise)])
days <- make_days(SEASONS, ufs = c("BA", CONTROL))
days[, ba := as.integer(uf == "BA")]
days[, bw := ba * win]

# ── Placebo in time: one coefficient per season ─────────────────────────────
cases <- CJ(outcome = TRAFFIC, side = c("set", "rise"), sorted = FALSE)
res <- rbindlist(lapply(seq_len(nrow(cases)), function(i) {
  cs <- cases[i]
  p <- make_panel(ev, days, cs$outcome, 0L, cs$side)
  rbindlist(lapply(SEASONS, function(s) {
    p[, x := bw * as.integer(sy == s)]
    m <- fepois(as.formula(paste("y ~ x", FE)), data = p, notes = FALSE, warn = FALSE)
    data.table(cs, sy = s, coef = coef(m)[["x"]],
               ba_win_events = p[ba == 1 & win == 1 & sy == s, sum(y)])
  }))
}))
# Rank of the DST season: evening should be the lowest, morning the highest.
rank_tab <- res[, .(coef_2011_lp = 100 * coef[sy == BA_SEASON],
                    placebo_min_lp = 100 * min(coef[sy != BA_SEASON]),
                    placebo_max_lp = 100 * max(coef[sy != BA_SEASON]),
                    rank_from_bottom = sum(coef <= coef[sy == BA_SEASON]),
                    n_seasons = .N,
                    ba_events_2011 = ba_win_events[sy == BA_SEASON],
                    ba_events_other_mean = mean(ba_win_events[sy != BA_SEASON])),
                by = .(outcome, side)]

# ── First stage: PRF dark share in BA's evening hour 0, summer window ───────
# fase_dia travels with each accident, so no join by time is needed.
fs <- ev_ba[outcome == "PRF injury accidents" & bin_set == 0L & !is.na(fase_dia)]
fs <- days[uf == "BA", .(date, window, sy)][fs, on = "date", nomatch = 0][window == "win"]
fs_tab <- fs[, .(dark_pct = round(100 * mean(fase_dia %in% c("anoitecer", "plena noite")), 1),
                                 n = .N), keyby = sy]

# Figure: drawn by 20_figures.R from the cache saved below.

saveRDS(list(by_season = res, rank = rank_tab, first_stage = fs_tab, seasons = SEASONS),
        file.path(path_audit, "bahia_switch.rds"))
options(width = 180)
print(rank_tab[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
cat("\nFirst stage, BA evening hour 0, summer: PRF accidents recorded dusk/night (%)\n")
print(fs_tab)
