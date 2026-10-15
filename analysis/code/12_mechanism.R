# =============================================================================
# 12_mechanism.R
#
# Who dies in the hour that turned dark? Light should matter most for people
# outside a vehicle: the literature (Sullivan & Flannagan 2002; IIHS 2024)
# finds that pedestrian risk tracks ambient light and occupant risk barely
# does. Split of the light-switched-hour triple difference:
#   SIM on-road transport deaths: pedestrians (V01-V09) vs everyone else
#   PRF: "atropelamento de pessoa / pedestre" vs every other accident type,
#        deaths and injury accidents
# Hours: evening 0 and +1, morning 0 (the hours whose light changed; see 11).
#
# One stacked Poisson per pair, fixed effects interacted with group x hour, so
# each coefficient equals its separate triple difference and the pedestrian -
# other difference gets a UF-clustered standard error. Excess per season as in
# 11_reallocation.R.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
N_POST <- sum(SEASONS > LAST_PRE)

PAIRS <- list(
  "SIM deaths, on road" = c(ped = "SIM pedestrian deaths, on road",
                            other = "SIM non-pedestrian deaths, on road"),
  "PRF deaths"          = c(ped = "PRF pedestrian deaths", other = "PRF non-pedestrian deaths"),
  "PRF injury accidents" = c(ped = "PRF pedestrian injury accidents",
                             other = "PRF non-pedestrian injury accidents"))
HOURS <- data.table(side = c("set", "set", "rise"), bin = c(0L, 1L, 0L),
                    hour = c("eve+0", "eve+1", "morn+0"))

res <- list(); shares <- list()
for (nm in names(PAIRS)) {
  p <- rbindlist(lapply(names(PAIRS[[nm]]), function(g) rbindlist(lapply(seq_len(nrow(HOURS)), function(i) {
    x <- make_panel(ev, days, PAIRS[[nm]][[g]], HOURS$bin[i], HOURS$side[i])
    x[, `:=`(group = g, hour = HOURS$hour[i])]
  }))))
  p[, key := paste(group, hour, sep = "_")]
  m <- fepois(y ~ i(key, twp) | uf^window^key + uf^sy^key + date^key, data = p, cluster = ~uf)
  b <- coef(m); V <- vcov(m)
  k <- sub("key::(.*):twp", "\\1", names(b))
  S <- p[twp == 1, .(S = sum(y)), by = key][match(k, key), S]
  pre <- p[tw == 1 & post == 0, .(pre = sum(y) / sum(SEASONS <= LAST_PRE)), by = key][match(k, key), pre]
  tab <- data.table(pair = nm, group = sub("_.*", "", k), hour = sub(".*_", "", k),
                    coef_lp = 100 * b, se_lp = 100 * sqrt(diag(V)),
                    pre_per_season = pre, excess_per_season = S * (1 - exp(-b)) / N_POST,
                    excess_se = sqrt(diag(V)) * S * exp(-b) / N_POST)
  # Pedestrian minus other, same hour.
  for (h in HOURS$hour) {
    w <- (k == paste0("ped_", h)) - (k == paste0("other_", h))
    tab <- rbind(tab, data.table(pair = nm, group = "ped - other", hour = h,
                                 coef_lp = 100 * sum(w * b), se_lp = 100 * sqrt(drop(t(w) %*% V %*% w))),
                 fill = TRUE)
  }
  res[[nm]] <- tab
  # Pedestrian share of the excess in each hour, E_ped / (E_ped + E_other),
  # with a delta-method standard error from the joint covariance.
  shares[[nm]] <- rbindlist(lapply(HOURS$hour, function(h) {
    i <- match(paste0(c("ped_", "other_"), h), k)
    E <- S[i] * (1 - exp(-b[i])); g <- S[i] * exp(-b[i]); tot <- sum(E)
    grad <- numeric(length(b))
    grad[i] <- c(g[1] * E[2], -g[2] * E[1]) / tot^2
    data.table(pair = nm, hour = h, group = "ped", share_se = 100 * sqrt(drop(t(grad) %*% V %*% grad)))
  }))
}
shares <- rbindlist(shares)
res <- rbindlist(res)
res[, p := 2 * pnorm(-abs(coef_lp / se_lp))]
res[, pct := 100 * (exp(coef_lp / 100) - 1)]
res[group != "ped - other", share_of_excess := 100 * excess_per_season /
      sum(excess_per_season), by = .(pair, hour)]
res <- shares[res, on = .(pair, hour, group)]


options(width = 180)
print(res[order(pair, hour, group), lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])

# ── Pre-trend check, evening hour 0, each split outcome ─────────────────────
# Linear treated x window trend fitted on pre seasons only, then extrapolated
# as an offset (as in 10_assault_trends.R); joint Wald test on the pre-season
# event-study coefficients (ref. 2018/19).
pre_terms <- sprintf("sy::(%s):tw", paste(SEASONS[SEASONS < LAST_PRE], collapse = "|"))
trend <- rbindlist(lapply(unlist(PAIRS), function(o) {
  x  <- make_panel(ev, days, o, 0L, "set")
  es <- fepois(as.formula(paste("y ~ i(sy, tw, ref = LAST_PRE)", FE)), data = x, cluster = ~uf)
  tr <- fepois(as.formula(paste("y ~ tw:t", FE)), data = x[post == 0], cluster = ~uf)
  x[, off := tw * t * coef(tr)[["tw:t"]]]
  ex <- fepois(as.formula(paste("y ~ twp", FE)), data = x, offset = ~off, cluster = ~uf)
  data.table(outcome = o, wald_pre_p = wald(es, keep = pre_terms, print = FALSE)$p,
             pre_trend_lp = 100 * coef(tr)[[1]], pre_trend_se = 100 * se(tr)[[1]],
             extrap_lp = 100 * coef(ex)[["twp"]], extrap_se = 100 * se(ex)[["twp"]])
}))
saveRDS(list(split = res, trend = trend), file.path(path_audit, "mechanism.rds"))
print(trend[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
