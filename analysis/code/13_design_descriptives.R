# =============================================================================
# 13_design_descriptives.R
#
# Table 1 numbers: events per season by group x window x period, whole day and
# evening hour 0, for the traffic outcomes and the pedestrian split. Cached in
# audit/table1.rds; the LaTeX is written by 29_tables.R and the design figure
# (Sao Paulo, 2018/19) is drawn by 28_figures.R.
#
# Also the national count that opens the paper: land-transport deaths
# (V01-V89, any place of occurrence, the whole country) and the pedestrian
# share, by calendar year of the consolidated death register. Cached in
# audit/national_road_deaths.rds.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))

# ── Table 1 ─────────────────────────────────────────────────────────────────
OUT <- c("SIM transport deaths, on road", "SIM pedestrian deaths, on road",
         "PRF deaths", "PRF pedestrian deaths", "PRF injury accidents")
dd <- days[, .(uf, date, window, sy, treated, post)]
e  <- dd[ev[outcome %in% OUT], on = .(uf, date), nomatch = 0]
nseas <- c(pre = sum(SEASONS <= LAST_PRE), post = sum(SEASONS > LAST_PRE))
tab <- rbind(
  e[, .(n = sum(w)), by = .(outcome, treated, window, post)][, scope := "whole day"],
  e[bin_set == 0, .(n = sum(w)), by = .(outcome, treated, window, post)][, scope := "evening hour 0"])
tab[, `:=`(group = fifelse(treated == 1, "Treated", "Control"),
           period = fifelse(post == 1, "post", "pre"))]
tab[, per_season := n / nseas[period]]
t1 <- dcast(tab, outcome + scope ~ group + window + period, value.var = "per_season")
t1[, outcome := factor(outcome, levels = OUT)]
t1[, scope := factor(scope, levels = c("whole day", "evening hour 0"))]
setorder(t1, outcome, scope)
cols <- c("Treated_win_pre", "Treated_win_post", "Treated_off_pre", "Treated_off_post",
          "Control_win_pre", "Control_win_post", "Control_off_pre", "Control_off_post")
setcolorder(t1, c("outcome", "scope", cols))

saveRDS(t1, file.path(path_audit, "table1.rds"))
options(width = 200)
print(t1[, c(list(outcome = outcome, scope = scope), lapply(.SD, round, 1)), .SDcols = cols])

# ── National land-transport deaths, by year ─────────────────────────────────
nat <- rbindlist(lapply(sim_years(), function(y) {
  s <- as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                                  col_select = c("CAUSABAS", "preliminary")))
  stopifnot(!any(s$preliminary))
  s <- s[CAUSABAS >= "V01" & CAUSABAS < "V90"]
  data.table(year = y, land_transport_deaths = nrow(s), pedestrian_deaths = s[CAUSABAS < "V10", .N])
}))
nat[, pedestrian_pct := 100 * pedestrian_deaths / land_transport_deaths]
saveRDS(nat, file.path(path_audit, "national_road_deaths.rds"))
print(nat[, .(year, land_transport_deaths, pedestrian_deaths, pedestrian_pct = round(pedestrian_pct, 1))])
