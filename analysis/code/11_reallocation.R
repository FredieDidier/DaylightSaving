# =============================================================================
# 11_reallocation.R
#
# Closing the account of the reallocation. Abolition darkened one evening hour
# and lightened one morning hour; the whole-day total does not move. How many
# deaths and crashes per season did the evening gain, how many did the morning
# lose, and what is the net?
#
# Hours (60-minute bins relative to STANDARD-time sunset / sunrise, as in 01):
#   evening -2, -1, 0, +1   (0 turned dark; +1 went from twilight to night;
#                            -1 and -2 lost some late-afternoon light)
#   morning -1, 0, +1       (0 turned light)
# One stacked Poisson model, every fixed effect interacted with the hour:
#
#   y[u,d,k] ~ sum_k beta_k 1[k] x treated x window x post
#              | uf^window^k + uf^sy^k + date^k
#
# The likelihood separates by hour, so each beta_k equals the separate triple
# difference of 01; stacking gives their joint UF-clustered covariance, which
# the sums below need.
#
# Excess events in hour k over the post seasons, treated states, summer window:
#   E_k = S_k (1 - exp(-beta_k)),  S_k = observed events in those cells,
# i.e. observed minus the counterfactual S_k exp(-beta_k). Sums of E_k get
# delta-method standard errors (gradient S_k exp(-beta_k)). Reported per
# season (divided by the number of post seasons).
#
# The same quantity for the whole day (every event with a clock time) comes
# from a separate model and is reported alongside, not summed.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(fixest))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))
N_POST <- sum(SEASONS > LAST_PRE)

HOURS <- rbind(data.table(side = "set",  bin = -2:1),
               data.table(side = "rise", bin = -1:1))
HOURS[, key := sprintf("%s%+d", fifelse(side == "set", "eve", "morn"), bin)]

# Groups of hours whose excess is summed.
SUMS <- list(
  "evening, dark (0, +1)"            = c("eve+0", "eve+1"),
  "evening, all (-2 to +1)"          = c("eve-2", "eve-1", "eve+0", "eve+1"),
  "morning, light (0)"               = "morn+0",
  "net: evening 0, +1 and morning 0" = c("eve+0", "eve+1", "morn+0"),
  "net: all seven hours"             = HOURS$key)

stack_panel <- function(o) {
  rbindlist(lapply(seq_len(nrow(HOURS)), function(i) {
    p <- make_panel(ev, days, o, HOURS$bin[i], HOURS$side[i])
    p[, key := HOURS$key[i]]
  }))
}

out <- list(); sums <- list()
for (o in TRAFFIC) {
  p <- stack_panel(o)
  m <- fepois(y ~ i(key, twp) | uf^window^key + uf^sy^key + date^key,
              data = p, cluster = ~uf)
  b <- coef(m); V <- vcov(m)
  k <- sub("key::(.*):twp", "\\1", names(b))
  S <- p[twp == 1, .(S = sum(y)), by = key][match(k, key), S]
  base_pre <- p[tw == 1 & post == 0, .(pre = sum(y) / sum(SEASONS <= LAST_PRE)), by = key][match(k, key), pre]
  E <- S * (1 - exp(-b)); g <- S * exp(-b)
  out[[o]] <- data.table(outcome = o, hour = k, coef_lp = 100 * b, se_lp = 100 * sqrt(diag(V)),
                         obs_per_season = S / N_POST, pre_per_season = base_pre,
                         excess_per_season = E / N_POST,
                         excess_se = sqrt(diag(V)) * g / N_POST)
  sums[[o]] <- rbindlist(lapply(names(SUMS), function(s) {
    w <- as.numeric(k %in% SUMS[[s]])
    data.table(outcome = o, sum = s, excess_per_season = sum(w * E) / N_POST,
               se = sqrt(drop(t(w * g) %*% V %*% (w * g))) / N_POST,
               counterfactual_per_season = sum(w * S * exp(-b)) / N_POST)
  }))
  # Whole day: every event with a clock time, one model.
  d <- ev[outcome == o, .(y = sum(w)), by = .(uf, date)][days, on = .(uf, date)]
  d[is.na(y), y := 0]
  md <- fepois(as.formula(paste("y ~ twp", FE)), data = d, cluster = ~uf)
  Sd <- d[twp == 1, sum(y)]; bd <- coef(md)[["twp"]]
  sums[[paste(o, "day")]] <- data.table(
    outcome = o, sum = "whole day (separate model)",
    excess_per_season = Sd * (1 - exp(-bd)) / N_POST,
    se = se(md)[["twp"]] * Sd * exp(-bd) / N_POST,
    counterfactual_per_season = Sd * exp(-bd) / N_POST)
}
out <- rbindlist(out); sums <- rbindlist(sums)
sums[, `:=`(pct_of_cf = 100 * excess_per_season / counterfactual_per_season,
            p = 2 * pnorm(-abs(excess_per_season / se)))]

# Check: stacked coefficients equal the separate fits of 01 for bin 0.
chk <- readRDS(file.path(path_audit, "sunset_design.rds"))$results
chk <- chk[bin == 0 & grepl("^evening", side) & outcome %in% TRAFFIC, .(outcome, lp02 = 100 * coef)]
chk <- out[hour == "eve+0", .(outcome, lp12 = coef_lp)][chk, on = "outcome"]
stopifnot(chk[, max(abs(lp12 - lp02))] < 0.1)

saveRDS(list(hours = out, sums = sums, n_post = N_POST),
        file.path(path_audit, "reallocation.rds"))
options(width = 180)
cat("Per hour (events per season, treated states, summer window):\n")
print(out[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 1) else x)])
cat("\nSums (events per season):\n")
print(sums[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])
