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
# (b) Darkness as a dose, from the sun. For each municipal seat, date and
#     clock hour h, the darkness index (dark_minutes, 00_utils.R: night 1,
#     civil twilight 1/2, daylight 0) of standard-time [60h, 60h + 60) minus
#     that of [60h - 60, 60h): under DST, clock hour h was standard hour h - 1,
#     so this is the change abolition brought to that clock hour. Averaged over
#     the state's seats, weighted by their on-road deaths (all hours, all
#     seasons). It runs from +1 (an evening hour that went from full daylight
#     to night) to -1 (a morning hour that went the other way) and sums to
#     zero over the day: abolition moved light, it did not remove any.
#     Panel: state x date x clock hour (0-23), summer window and off-season.
#       y[u,d,h] ~ te Xe + tm Xm | uf^h^window + uf^h^sy + h^date
#     X = dose x treated x window x post, split at noon into the evening (e)
#     and the morning (m). te is the change, in log points, when an evening
#     clock hour goes from fully light to fully dark. The clock-hour x date
#     effect absorbs any change, anywhere in the country, in the risk at a
#     given clock time on a given date, so the clock time at which the
#     treated states' hour 0 falls cannot drive te. Variants: date effects
#     only (no clock-hour x date); adding state x date effects (within the
#     state's day); adding a free effect for every clock hour in the treated
#     states' summers after 2019, so that te comes only from differences in
#     darkness at the same clock hour, which arise because the sun sets at
#     different clock times across the treated states and the summer's dates.
#     Every hour enters, with zero dose where the light did not change, so the
#     model gives a net count of excess events per summer without choosing
#     hours (as in 11: observed minus counterfactual, delta-method standard
#     errors). The same coefficients applied to the days of the 2017 rule's
#     DST season outside the summer window (first Sunday of November to 14
#     November; 15 February to the day before the third Sunday of February, a
#     week later when that Sunday is Carnival) give the count per DST season.
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
suppressPackageStartupMessages(library(fixest))

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

m_fs <- feols(dark ~ twp | uf^window + uf^sy + date, data = fs_dat, cluster = ~uf)
fs <- data.table(fs_pp = 100 * coef(m_fs)[["twp"]], fs_se_pp = 100 * se(m_fs)[["twp"]],
                 treated_pre_dark_pct = 100 * fs_dat[tw == 1 & post == 0, mean(dark)],
                 n_crashes = nrow(fs_dat))

# ── (b) Darkness dose ───────────────────────────────────────────────────────
N_POST <- sum(SEASONS > LAST_PRE)
post_s <- SEASONS[SEASONS > LAST_PRE]
# Days of the 2017 rule's DST season outside the summer window, post seasons.
nth_sunday <- function(y, mo, n) {
  d <- as.IDate(sprintf("%d-%02d-01", y, mo))
  d + (7L - wday(d) + 1L) %% 7L + 7L * (n - 1L)
}
extra <- rbindlist(lapply(post_s, function(s) {
  start <- nth_sunday(s, 11L, 1L)
  end   <- nth_sunday(s + 1L, 2L, 3L)
  if (end == easter_date(s + 1L) - 49L) end <- end + 7L
  d <- c(seq(start, as.IDate(sprintf("%d-11-14", s)), by = 1L),
         if (end > as.IDate(sprintf("%d-02-15", s + 1L)))
           seq(as.IDate(sprintf("%d-02-15", s + 1L)), end - 1L, by = 1L))
  data.table(sy = s, date = as.IDate(d))
}))
wt <- ev[outcome == "SIM transport deaths, on road" & uf %in% TREATED, .(n = .N), by = .(uf, code6)]
wt <- geo[, .(code6, lat, lon, std_offset_h)][wt, on = "code6", nomatch = 0]
dose_dates <- sort(unique(c(days[window == "win", date], extra$date)))
dose <- rbindlist(lapply(dose_dates, function(x) {
  s1 <- sun_times(rep(x, nrow(wt)), wt$lat, wt$lon, wt$std_offset_h)
  s6 <- sun_times(rep(x, nrow(wt)), wt$lat, wt$lon, wt$std_offset_h, zenith = 96)
  rbindlist(lapply(0:23, function(h) {
    dk <- function(lo) dark_minutes(lo, lo + 60, s6$sunrise, s1$sunrise, s1$sunset, s6$sunset)
    data.table(uf = wt$uf, h = h, d = (dk(60 * h) - dk(60 * h - 60)) / 60, n = wt$n)
  }))[, .(date = x, dose = sum(n * d) / sum(n)), by = .(uf, h)]
}))
# The doses of a state-day sum to zero (light is moved, not removed).
stopifnot(dose[, abs(sum(dose)), by = .(uf, date)][, max(V1)] < 1e-9)

hour_panel <- function(o, d) {
  y <- ev[outcome == o, .(y = sum(w)), by = .(uf, date, h = cmin %/% 60L)]
  p <- d[, .(h = 0:23), by = .(uf, date, window, sy, treated, win, post, tw, twp)]
  p <- y[p, on = .(uf, date, h)][is.na(y), y := 0]
  p <- dose[p, on = .(uf, date, h)][is.na(dose), dose := 0]
  p[, `:=`(xe = dose * twp * (h >= 12L), xm = dose * twp * (h < 12L))]
  p[]
}
DOSE_FE <- c(clock_blind = "| uf^h^window + uf^h^sy + date",
             main        = "| uf^h^window + uf^h^sy + h^date",
             within_day  = "| uf^date + uf^h^window + uf^h^sy + h^date",
             hour_free   = "| uf^h^window + uf^h^sy + h^date")
excess <- function(q, b, V) {
  eta <- q$xe * b[["xe"]] + q$xm * b[["xm"]]
  part <- function(x, bb) sum(q$y * (1 - exp(-x * bb))) / N_POST
  g <- c(xe = sum(q$y * exp(-eta) * q$xe), xm = sum(q$y * exp(-eta) * q$xm)) / N_POST
  data.table(net = sum(q$y * (1 - exp(-eta))) / N_POST, net_se = sqrt(drop(t(g) %*% V %*% g)),
             evening = part(q$xe, b[["xe"]]), morning = part(q$xm, b[["xm"]]),
             counterfactual = sum(q$y * exp(-eta)) / N_POST)
}
DOSE_OUT <- c(TRAFFIC, "SIM pedestrian deaths, on road", "SIM non-pedestrian deaths, on road")
dose_res <- rbindlist(lapply(DOSE_OUT, function(o) {
  p <- hour_panel(o, days)
  specs <- if (o %in% TRAFFIC) names(DOSE_FE) else "main"
  rbindlist(lapply(specs, function(sp) {
    rhs <- "y ~ xe + xm"
    if (sp == "hour_free") {
      p[, hT := fifelse(twp == 1L, paste0("h", h), "none")]
      rhs <- paste(rhs, "+ i(hT, ref = \"none\")")
    }
    m <- fepois(as.formula(paste(rhs, DOSE_FE[[sp]])), data = p, cluster = ~uf, notes = FALSE)
    b <- coef(m)[c("xe", "xm")]; V <- vcov(m)[c("xe", "xm"), c("xe", "xm")]
    out <- data.table(outcome = o, spec = sp, evening_lp = 100 * b[["xe"]],
                      evening_se = 100 * sqrt(V[1, 1]), morning_lp = 100 * b[["xm"]],
                      morning_se = 100 * sqrt(V[2, 2]),
                      diff_p = 2 * pnorm(-abs((b[["xe"]] - b[["xm"]]) /
                                                sqrt(V[1, 1] + V[2, 2] - 2 * V[1, 2]))),
                      n_obs = nobs(m))
    ex <- excess(p[twp == 1L & (xe != 0 | xm != 0)], b, V)
    out <- cbind(out, ex)
    if (sp == "main") {
      # The whole DST season: summer-window cells plus the season days outside
      # the window, treated states, seasons after abolition.
      q <- hour_panel(o, unique(days[, .(uf, treated)])[treated == 1L][
        , .(date = extra$date, sy = extra$sy), by = .(uf, treated)][
        , `:=`(window = "season", win = 1L, post = 1L, tw = 1L, twp = 1L)])
      both <- rbind(p[twp == 1L & (xe != 0 | xm != 0)], q[xe != 0 | xm != 0], fill = TRUE)
      es <- excess(both, b, V)
      out[, `:=`(season_net = es$net, season_net_se = es$net_se,
                 extra_days_per_season = nrow(extra) / N_POST)]
    }
    out
  }), fill = TRUE)
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

saveRDS(list(first_stage = fs, dose = dose_res, rain = rain_res),
        file.path(path_audit, "light_dose.rds"))
options(width = 200)
print(fs)
print(dose_res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])
print(rain_res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])
