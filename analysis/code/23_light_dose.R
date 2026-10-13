# =============================================================================
# 23_light_dose.R
#
# How much darkness, and does the effect scale with it?
#
# (a) First stage in the evening hour 0 itself. Federal highway crashes in
#     clock [sunset_std, + 60 min) in the 23 states; dark = 1 when the officer
#     recorded dusk or night (among full day, dusk, night; as in 03). Linear
#     triple difference at the crash level,
#       dark ~ treated x window x post | uf^window + uf^sy + date,
#     clustered by state. The share is among crashes that happened, so it mixes
#     the change in light with the change in which crashes happen; it is a
#     scale, not a structural first stage.
# (b) Wald ratio: the reduced form of 01 (log points) divided by (a)
#     (percentage points), times 100: the change in events when the hour goes
#     from light to fully dark. The PRF first stage scales the SIM estimate too
#     (same hour, same places; federal highways only). 95% interval from a
#     pairs bootstrap over states (DS_BOOT draws, default 499; states drawn
#     with replacement, duplicates relabelled; draws fixed up front).
# (c) Rain. On a rainy, overcast evening the hour was already dim under DST,
#     so abolition darkens it less. Rain index per state-day: share of the
#     state's on-road deaths (all hours, all seasons, by municipality) that
#     live in municipalities with >= 1 mm of rain that day (Xavier BR-DWGD at
#     the seat, build/08_xavier_rain.R). Two uses: rain as a control in the
#     main specification, and the rain share interacted with every term of
#     the triple difference (does the effect shrink on rainy days?).
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
  library(parallel)
})

B     <- as.integer(Sys.getenv("DS_BOOT", unset = "499"))
CORES <- as.integer(Sys.getenv("DS_CORES", unset = "4"))
set.seed(20190425)
setFixest_nthreads(1)

SEASONS <- season_range()
days <- make_days(SEASONS)
geo  <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output",
                                             "muni_geo.parquet")))
ev   <- as.data.table(read_parquet(EVENTS_FILE))

# ── PRF crashes in evening hour 0 with the recorded light phase (as in 01) ──
prf <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "prf", "output",
                                            "prf_accidents.parquet")))[mortos > 0 | feridos > 0]
norm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
geo[, key := paste(uf, norm(name))]
alias <- fread(file.path(path_manual, "prf_municipio_alias.csv"), encoding = "UTF-8")
alias <- alias[, .(key = paste(uf, norm(municipio_prf)), code6)]
keys <- rbind(unique(geo[, .(key, code6)], by = "key"), alias[!key %in% geo$key])
stopifnot(!anyDuplicated(keys$key))
prf[, key := paste(uf, norm(municipio))]
prf <- keys[prf, on = "key"]
prf <- geo[, .(code6, uf_geo = uf, lat, lon, std_offset_h)][prf, on = "code6", nomatch = 0]
prf[, bin_set := floor((60L * hour + minute - sun_times(date, lat, lon, std_offset_h)$sunset) / 60)]
fs_dat <- prf[bin_set == 0L & fase_dia %in% c("pleno dia", "anoitecer", "plena noite"),
              .(uf = uf_geo, date = as.IDate(date), dark = as.integer(fase_dia != "pleno dia"))]
fs_dat <- days[, .(uf, date, window, sy, twp, tw, post)][fs_dat, on = .(uf, date), nomatch = 0]
# Guard: the hour-0 injury crashes here are the 01 event file's.
stopifnot(abs(nrow(fs_dat) - ev[outcome == "PRF injury accidents" & bin_set == 0L &
                                  date %in% days$date, .N]) / nrow(fs_dat) < 0.01)

fs_fit <- function(d) coef(feols(dark ~ twp | uf^window + uf^sy + date, data = d))[["twp"]]
m_fs <- feols(dark ~ twp | uf^window + uf^sy + date, data = fs_dat, cluster = ~uf)
fs <- data.table(fs_pp = 100 * coef(m_fs)[["twp"]], fs_se_pp = 100 * se(m_fs)[["twp"]],
                 treated_pre_dark_pct = 100 * fs_dat[tw == 1 & post == 0, mean(dark)],
                 n_crashes = nrow(fs_dat))

# ── Reduced forms and the Wald ratio ────────────────────────────────────────
panels <- lapply(setNames(TRAFFIC, TRAFFIC), function(o) make_panel(ev, days, o, 0L, "set"))
rf_fit <- function(p) coef(fepois(as.formula(paste("y ~ twp", FE)), data = p, notes = FALSE))[["twp"]]
rf <- sapply(panels, rf_fit)

ALL <- c(TREATED, CONTROL)
draws <- replicate(B, sample(ALL, length(ALL), replace = TRUE), simplify = FALSE)
resample <- function(d, s) rbindlist(lapply(seq_along(s), function(i)
  d[uf == s[i]][, uf := paste0(s[i], "_", i)]))
boot <- do.call(rbind, mclapply(draws, function(s) {
  if (!any(s %in% TREATED) || !any(s %in% CONTROL)) return(rep(NA_real_, 4))
  c(fs = tryCatch(fs_fit(resample(fs_dat, s)), error = function(e) NA_real_),
    sapply(panels, function(p) tryCatch(rf_fit(resample(p, s)), error = function(e) NA_real_)))
}, mc.cores = CORES))
colnames(boot) <- c("fs", TRAFFIC)

wald <- rbindlist(lapply(TRAFFIC, function(o) {
  r <- 100 * boot[, o] / boot[, "fs"]
  data.table(outcome = o, rf_lp = 100 * rf[[o]], wald_lp_per_full_dark = 100 * rf[[o]] / coef(m_fs)[["twp"]],
             lo = quantile(r, 0.025, na.rm = TRUE), hi = quantile(r, 0.975, na.rm = TRUE),
             n_boot_ok = sum(is.finite(r)))
}))

# ── Rain: effect on dry and rainy state-days ────────────────────────────────
pr <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "weather", "output",
                                           "pr_seat_day.parquet")))
pr[, date := as.IDate(date)]
w <- ev[outcome == "SIM transport deaths, on road", .(n = .N), by = .(uf, code6)]
w[, wt := n / sum(n), by = uf]
rain <- pr[date %in% days$date][w, on = "code6", nomatch = 0][
  , .(rain_share = sum(wt * (pr_mm >= 1)) / sum(wt)), by = .(uf, date)]
days_r <- rain[days, on = .(uf, date)]
stopifnot(!anyNA(days_r$rain_share))
days_r[, rainy := as.integer(rain_share >= 0.5)]

rain_res <- rbindlist(lapply(TRAFFIC, function(o) {
  p <- make_panel(ev, days, o, 0L, "set")[days_r[, .(uf, date, rain_share, rainy)], on = .(uf, date)]
  # (i) Rain as a control: the main estimate should not move.
  m0 <- fepois(as.formula(paste("y ~ twp + rain_share", FE)), data = p, cluster = ~uf, notes = FALSE)
  # (ii) Does the effect shrink on rainy days? The rain share (0-1) interacts
  # with every term of the triple difference, fixed effects kept common. The
  # coefficient on twp:rain_share is the change in the effect from a dry to a
  # fully rainy state-day. Interacting the fixed effects themselves with a
  # rainy indicator (date x rainy cells) drops ~22% of the panel as all-zero
  # groups and changes the sample, so it is not used.
  m1 <- fepois(as.formula(paste("y ~ twp + twp:rain_share + rain_share + rain_share:treated +",
                                "rain_share:win + rain_share:post + rain_share:tw +",
                                "rain_share:treated:post + rain_share:win:post", FE)),
               data = p, cluster = ~uf, notes = FALSE)
  data.table(outcome = o,
             with_rain_control_lp = 100 * coef(m0)[["twp"]], with_rain_control_se = 100 * se(m0)[["twp"]],
             effect_dry_lp = 100 * coef(m1)[["twp"]], effect_dry_se = 100 * se(m1)[["twp"]],
             rain_change_lp = 100 * coef(m1)[["twp:rain_share"]], rain_change_se = 100 * se(m1)[["twp:rain_share"]],
             rain_change_p = pvalue(m1)[["twp:rain_share"]],
             mean_rain_share_win = p[win == 1, mean(rain_share)])
}))

saveRDS(list(first_stage = fs, wald = wald, rain = rain_res, n_boot = B),
        file.path(path_audit, "light_dose.rds"))
options(width = 160)
print(fs); print(wald); print(rain_res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])
