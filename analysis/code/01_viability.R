# =============================================================================
# 01_viability.R
#
# Go / no-go evidence. Three questions:
#   1. First stage: did abolition make the evening darker where it should?
#      PRF officers record the light phase of every accident (fase_dia). At
#      clock 18:00-19:59 in the DST window, the share recorded as dusk or night
#      should rise in treated states after 2019, and not in control states.
#   2. Reduced form by clock-hour bin: Poisson triple difference
#        y[u,d] ~ treated_u x win_d x post_d | uf x window + uf x season + date
#      for transport deaths (SIM), assault deaths (SIM), PRF deaths and PRF
#      injury accidents. Expected signs if light matters: up at dusk (17-20),
#      down at dawn (5-8).
#   3. Event study by season (ref. 2018/19, the last DST season) for the same
#      outcomes: are there pre-trends, and is the post jump visible?
#
# Groups, windows and seasons as in 00_first_look.R. Standard errors clustered
# by UF (23 clusters); treat p-values as indicative until wild bootstrap /
# permutation inference is added.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))     # season frame, figure style
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(fixest)
  library(ggplot2)
})

TREATED <- c("RS", "SC", "PR", "SP", "RJ", "ES", "MG", "GO", "MT", "MS", "DF")
CONTROL <- c("RO", "RR", "PA", "AP", "MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE")
UF_CODE <- c(RO = 11, RR = 14, PA = 15, AP = 16, MA = 21, PI = 22, CE = 23,
             RN = 24, PB = 25, PE = 26, AL = 27, SE = 28, MG = 31, ES = 32,
             RJ = 33, SP = 35, PR = 41, SC = 42, RS = 43, MS = 50, MT = 51,
             GO = 52, DF = 53)
code_to_uf <- setNames(names(UF_CODE), UF_CODE)
SEASONS <- season_range()
BINS <- data.table(hour = 0:23,
                   bin = cut(0:23, c(-1, 4, 7, 16, 19, 23),
                             labels = c("night 0-5", "dawn 5-8", "day 8-17",
                                        "dusk 17-20", "evening 20-24")))

# Day-level frame: every UF x day in the two windows, with design variables.
days <- make_days(SEASONS)

parse_hour <- function(x) {
  h <- suppressWarnings(as.integer(substr(x, 1, 2)))
  fifelse(nchar(x) == 4L & h %between% c(0L, 23L), h, NA_integer_)
}

# ── Events: SIM ─────────────────────────────────────────────────────────────
sim <- rbindlist(lapply((min(SEASONS)):(max(SEASONS) + 1L), function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR",
                                            "CAUSABAS", "preliminary")))))
sim <- sim[preliminary == FALSE]
sim[, `:=`(date = as.IDate(DTOBITO, format = "%d%m%Y"), hour = parse_hour(HORAOBITO),
           uf = code_to_uf[substr(CODMUNOCOR, 1, 2)])]
sim[, outcome := fcase(CAUSABAS >= "V01" & CAUSABAS < "V90", "SIM transport deaths",
                       CAUSABAS >= "X85" & CAUSABAS < "Y10", "SIM assault deaths")]
ev_sim <- sim[!is.na(outcome) & !is.na(uf), .(uf, date, hour, outcome, w = 1L)]
rm(sim); gc()

# ── Events: PRF ─────────────────────────────────────────────────────────────
prf <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "prf", "output",
                                            "prf_accidents.parquet")))
ev_prf <- rbind(
  prf[mortos > 0, .(uf, date, hour, outcome = "PRF deaths", w = mortos)],
  prf[mortos > 0 | feridos > 0, .(uf, date, hour, outcome = "PRF injury accidents", w = 1L)])
ev <- rbind(ev_sim, ev_prf)[uf %in% c(TREATED, CONTROL) & !is.na(hour)]
ev <- BINS[ev, on = "hour"]
OUTCOMES <- c("SIM transport deaths", "PRF deaths", "PRF injury accidents",
              "SIM assault deaths")

# ── 1. First stage: light phase recorded by PRF at clock 18-19h ─────────────
fs <- prf[hour %in% 18:19 & uf %in% c(TREATED, CONTROL) & !is.na(fase_dia)]
fs[, dark := as.integer(fase_dia %in% c("anoitecer", "plena noite"))]
fs <- days[, .(uf, date, window, sy, treated, post)][fs, on = .(uf, date), nomatch = 0]
fs_tab <- fs[window == "win", .(dark_share = round(100 * mean(dark), 1), n = .N),
             by = .(group = fifelse(treated == 1, "treated", "control"),
                    period = fifelse(post == 1, "post", "pre"))]
fs[, tw := treated * (window == "win")]
fs_reg <- feols(dark ~ tw:post | uf^window + uf^sy + date, data = fs, cluster = ~uf)

# ── 2 & 3. Poisson triple differences ───────────────────────────────────────
count_panel <- function(o, b) {
  e <- if (b == "all day") ev[outcome == o] else ev[outcome == o & bin == b]
  y <- e[, .(y = sum(w)), by = .(uf, date)]
  p <- y[days, on = .(uf, date)]
  p[is.na(y), y := 0]
  p
}
grid <- CJ(outcome = OUTCOMES, bin = c("all day", levels(BINS$bin)), sorted = FALSE)
res <- grid[, {
  p <- count_panel(outcome, bin)
  m <- fepois(y ~ twp | uf^window + uf^sy + date, data = p, cluster = ~uf)
  .(coef = coef(m)[["twp"]], se = se(m)[["twp"]], mean_y = p[tw == 1 & post == 0, mean(y)],
    n_events = p[, sum(y)])
}, by = .(outcome, bin)]
res[, `:=`(pct = 100 * (exp(coef) - 1), lo = 100 * (exp(coef - 1.96 * se) - 1),
           hi = 100 * (exp(coef + 1.96 * se) - 1), p = 2 * pnorm(-abs(coef / se)))]

es <- rbindlist(lapply(OUTCOMES, function(o) rbindlist(lapply(c("all day", "dawn 5-8", "dusk 17-20"),
  function(b) {
    p <- count_panel(o, b)
    m <- fepois(y ~ i(sy, tw, ref = LAST_PRE) | uf^window + uf^sy + date, data = p, cluster = ~uf)
    ct <- as.data.table(coeftable(m), keep.rownames = "term")
    ct[, .(outcome = o, bin = b, sy = as.integer(sub("sy::(\\d+):tw", "\\1", term)),
           coef = Estimate, se = `Std. Error`)]
  }))))
es <- rbind(es, unique(es[, .(outcome, bin)])[, .(outcome, bin, sy = LAST_PRE, coef = 0, se = 0)])

# ── Outputs ─────────────────────────────────────────────────────────────────
OUT01 <- c("SIM transport deaths" = "Transport deaths (SIM)", "PRF deaths" = "Highway deaths (PRF)",
           "PRF injury accidents" = "Injury crashes (PRF)", "SIM assault deaths" = "Assault deaths (SIM)")
fig <- es[bin != "all day"]
fig[, outcome := factor(OUT01[outcome], levels = OUT01)]
fig[, bin := factor(fifelse(bin == "dawn 5-8", "Dawn, 5\u20138 a.m.", "Dusk, 5\u20138 p.m."),
                    levels = c("Dawn, 5\u20138 a.m.", "Dusk, 5\u20138 p.m."))]
dodge <- position_dodge(width = 0.55)
g <- ggplot(fig, aes(sy, 100 * coef, colour = bin, shape = bin)) +
  annotate("rect", xmin = LAST_PRE + 0.5, xmax = max(SEASONS) + 0.5, ymin = -Inf, ymax = Inf,
           fill = "grey93") +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_errorbar(aes(ymin = 100 * (coef - 1.96 * se), ymax = 100 * (coef + 1.96 * se)),
                width = 0, linewidth = 0.45, position = dodge) +
  geom_point(size = 1.6, position = dodge) +
  facet_wrap(~ outcome, ncol = 2, scales = "free_y") +
  scale_x_continuous(breaks = c(2010, 2014, 2018, 2022), labels = season_lab,
                     expand = expansion(add = 0.5)) +
  scale_y_continuous(labels = num_lab) +
  scale_colour_manual(values = setNames(c(PAL[["amber"]], PAL[["blue"]]), levels(fig$bin))) +
  scale_shape_manual(values = setNames(c(17, 16), levels(fig$bin))) +
  labs(x = "Season (shaded: after abolition; reference 2018/19)",
       y = "Treated \u00d7 summer window (log points)") +
  theme_paper()
save_fig(g, "fig01_viability_event_study", height = 5.6)

saveRDS(list(first_stage_table = fs_tab, first_stage_reg = coeftable(fs_reg),
             ddd = res, event_study = es),
        file.path(path_audit, "viability_numbers.rds"))

options(width = 160)
cat("\n== 1. First stage: share of PRF accidents at clock 18-19h recorded as dusk/night (DST window) ==\n")
print(fs_tab[order(group, -rank(period))])
print(coeftable(fs_reg))
cat("\n== 2. Poisson triple difference, treated x window x post (percent) ==\n")
print(res[, .(outcome, bin, pct = round(pct, 1), lo = round(lo, 1), hi = round(hi, 1),
              p = round(p, 3), mean_y_cell = round(mean_y, 2), n_events)])
