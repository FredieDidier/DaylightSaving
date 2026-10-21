# =============================================================================
# 10_assault_trends.R
#
# Is the rise in SIM assault deaths in treated states after abolition, spread
# over the day and over every place of death, an effect of light, or a
# differential trend in violence between the treated block (S/SE/CO) and the control
# (N/NE)? Light predicts an effect concentrated at the hour that turned dark;
# a trend predicts a level shift spread over the day, visible before 2019.
#
# Three checks, assault deaths (X85-Y09), all places, clock hour of death:
#   (a) event study by season of the triple difference (ref. 2018/19), for the
#       whole day and for fixed clock blocks; joint Wald test on pre seasons,
#       linear pre-trend, pooled estimate with the pre-trend extrapolated;
#   (b) the triple difference split into its two double differences:
#       treated x post inside the summer window and inside the off season. A
#       light effect lives in the window only; a trend in violence shows up in
#       both;
#       (a2) the pooled estimate without 2019/20, the first post season;
#   (c) the raw series: deaths per season by group and window.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages({
  library(fixest)
})

SEASONS <- season_range()
days <- make_days(SEASONS)
pre_s <- SEASONS[SEASONS < LAST_PRE]

parse_hour <- function(x) {
  h <- suppressWarnings(as.integer(substr(x, 1, 2)))
  fifelse(nchar(x) == 4L & h %between% c(0L, 23L), h, NA_integer_)
}

sim <- rbindlist(lapply((min(SEASONS)):(max(SEASONS) + 1L), function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR",
                                            "CAUSABAS", "preliminary")))))
stopifnot(!any(sim$preliminary))
sim <- sim[CAUSABAS >= "X85" & CAUSABAS < "Y10"]
sim[, `:=`(date = as.IDate(DTOBITO, format = "%d%m%Y"), hour = parse_hour(HORAOBITO),
           uf = code_to_uf[substr(CODMUNOCOR, 1, 2)])]
sim <- sim[uf %in% c(TREATED, CONTROL) & !is.na(date)]
sim[, block := fcase(is.na(hour), NA_character_,
                     hour < 8L, "0-8h", hour < 17L, "8-17h", hour < 20L, "17-20h",
                     default = "20-24h")]
BLOCKS <- c("all day", "0-8h", "8-17h", "17-20h", "20-24h")

panel <- function(b) {
  e <- if (b == "all day") sim else sim[block == b]
  y <- e[, .(y = .N), by = .(uf, date)]
  p <- y[days, on = .(uf, date)]
  p[is.na(y), y := 0]
  p[]
}
fit <- function(f, d, fe = FE) fepois(as.formula(paste(f, fe)), data = d, cluster = ~uf)
pre_terms <- sprintf("sy::(%s):tw", paste(pre_s, collapse = "|"))

# ── (a) Event study, pre-trend, extrapolated trend ──────────────────────────
res <- list(); es <- list()
for (b in BLOCKS) {
  p <- panel(b)
  m_es <- fit("y ~ i(sy, tw, ref = LAST_PRE)", p)
  ct <- as.data.table(coeftable(m_es), keep.rownames = "term")
  es[[b]] <- rbind(ct[, .(block = b, sy = as.integer(sub("sy::(\\d+):tw", "\\1", term)),
                          coef = Estimate, se = `Std. Error`)],
                   data.table(block = b, sy = LAST_PRE, coef = 0, se = 0))
  base <- fit("y ~ twp", p)
  tr   <- fit("y ~ tw:t", p[post == 0])
  # Pre-trend fitted on pre seasons only, extrapolated as an offset: the post
  # coefficient is then the deviation from the pre path (t = sy - 2018).
  p[, off := tw * t * coef(tr)[["tw:t"]]]
  extr <- fepois(as.formula(paste("y ~ twp", FE)), data = p, offset = ~off, cluster = ~uf)
  # Is the pooled effect one season? Drop the first post season.
  no19 <- fit("y ~ twp", p[sy != LAST_PRE + 1L])
  # (b) Double differences, treated x post, inside each window separately.
  dd <- sapply(c("win", "off"), function(w) {
    m <- fit("y ~ treated:post", p[window == w], fe = "| uf + date")
    c(coef(m)[[1]], se(m)[[1]])
  })
  res[[b]] <- data.table(
    block = b, n_events = p[, sum(y)],
    ddd_lp = 100 * coef(base)[["twp"]], ddd_se = 100 * se(base)[["twp"]],
    wald_pre_p = wald(m_es, keep = pre_terms, print = FALSE)$p,
    pre_trend_lp = 100 * coef(tr)[["tw:t"]], pre_trend_se = 100 * se(tr)[["tw:t"]],
    extrap_lp = 100 * coef(extr)[["twp"]], extrap_se = 100 * se(extr)[["twp"]],
    no1920_lp = 100 * coef(no19)[["twp"]], no1920_se = 100 * se(no19)[["twp"]],
    dd_win_lp = 100 * dd[1, "win"], dd_win_se = 100 * dd[2, "win"],
    dd_off_lp = 100 * dd[1, "off"], dd_off_se = 100 * dd[2, "off"])
}
res <- rbindlist(res); es <- rbindlist(es)
res[, ddd_p := 2 * pnorm(-abs(ddd_lp / ddd_se))]
res[, extrap_p := 2 * pnorm(-abs(extrap_lp / extrap_se))]

# ── (c) Raw series: deaths per season, group x window ───────────────────────
raw <- days[, .(uf, date, window, sy, treated)][sim[, .(uf, date)], on = .(uf, date), nomatch = 0]
raw <- raw[, .(deaths = .N), by = .(sy, group = fifelse(treated == 1, "treated", "control"), window)]
raw <- dcast(raw, sy ~ group + window, value.var = "deaths")
raw[, `:=`(ratio_treated = round(treated_win / treated_off, 3),
           ratio_control = round(control_win / control_off, 3))]
raw[, ddd_log := round(100 * (log(ratio_treated) - log(ratio_control)), 1)]

# Figure: drawn by 27_figures.R from the cache saved below.

saveRDS(list(results = res, event_study = es, raw = raw),
        file.path(path_audit, "assault_trends.rds"))
options(width = 200)
print(res[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 3) else x)])
cat("\nEvent study (log points):\n")
print(dcast(es, sy ~ block, value.var = "coef")[, lapply(.SD, function(x) round(100 * x, 1)), by = sy])
cat("\nRaw deaths per season:\n")
print(raw)
