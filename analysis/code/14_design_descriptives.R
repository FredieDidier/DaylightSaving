# =============================================================================
# 14_design_descriptives.R
#
# Two exhibits for the paper (horario_verao/PAPER.md):
#   fig07_design   Clock time of sunset and sunrise over the 2018/19 season in
#                  Sao Paulo (treated) under DST and under standard time; the
#                  summer window and the light-switched evening hour shaded.
#   table1         Descriptives: events per season by group x window x period,
#                  whole day and evening hour 0, for the traffic outcomes and
#                  the pedestrian split. CSV and LaTeX in analysis/output/tables.
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))
suppressPackageStartupMessages(library(ggplot2))

SEASONS <- season_range()
days <- make_days(SEASONS)
ev   <- as.data.table(read_parquet(EVENTS_FILE))

# ── Figure: the design in one city ──────────────────────────────────────────
d <- data.table(date = seq(as.Date("2018-07-01"), as.Date("2019-06-30"), by = "day"))
st <- sun_times(d$date, -23.55, -46.63, -3)
d[, `:=`(sunset = st$sunset / 60, sunrise = st$sunrise / 60)]
# DST in 2018/19: 4 Nov 2018 to 17 Feb 2019 (Decree 9,242/2017 rule).
d[, dst := as.integer(date >= as.Date("2018-11-04") & date < as.Date("2019-02-17"))]
long <- rbind(
  d[, .(date, h = sunset + dst, event = "Sunset", regime = "With DST (until 2018/19)")],
  d[, .(date, h = sunset, event = "Sunset", regime = "Without DST (from 2019/20)")],
  d[, .(date, h = sunrise + dst, event = "Sunrise", regime = "With DST (until 2018/19)")],
  d[, .(date, h = sunrise, event = "Sunrise", regime = "Without DST (from 2019/20)")])
long[, event := factor(event, levels = c("Sunset", "Sunrise"))]
win <- data.table(xmin = as.Date("2018-11-15"), xmax = as.Date("2019-02-14"))
band <- d[date >= win$xmin & date <= win$xmax,
          .(date, lo = sunset, hi = sunset + 1, event = factor("Sunset", levels = levels(long$event)))]
band_m <- d[date >= win$xmin & date <= win$xmax,
            .(date, lo = sunrise, hi = sunrise + 1, event = factor("Sunrise", levels = levels(long$event)))]
hfmt <- function(x) sprintf("%d:%02d", floor(x), round(60 * (x - floor(x))))
g <- ggplot(long, aes(date, h)) +
  annotate("rect", xmin = win$xmin, xmax = win$xmax, ymin = -Inf, ymax = Inf, fill = "grey93") +
  geom_ribbon(data = rbind(band, band_m), aes(x = date, ymin = lo, ymax = hi), inherit.aes = FALSE,
              fill = PAL[["red"]], alpha = 0.25) +
  geom_line(aes(colour = regime, linetype = regime), linewidth = 0.7) +
  facet_wrap(~ event, ncol = 2, scales = "free_y") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b") +
  scale_y_continuous(labels = hfmt) +
  scale_colour_manual(values = c(PAL[["red"]], PAL[["blue"]])) +
  scale_linetype_manual(values = c("solid", "longdash")) +
  labs(x = "Date (São Paulo, July 2018 – June 2019; grey: summer window)",
       y = "Clock time") +
  theme_paper()
save_fig(g, "fig07_design", height = 3.4)

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
dir.create(path_tables, recursive = TRUE, showWarnings = FALSE)
fwrite(t1[, c(list(outcome, scope), lapply(.SD, round, 1)), .SDcols = cols],
       file.path(path_tables, "table1_descriptives.csv"))

# LaTeX body (caption and notes live in the manuscript).
lab <- c("SIM transport deaths, on road" = "Road deaths (SIM)",
         "SIM pedestrian deaths, on road" = "\\quad pedestrians",
         "PRF deaths" = "Highway deaths (PRF)", "PRF pedestrian deaths" = "\\quad pedestrians",
         "PRF injury accidents" = "Injury crashes (PRF)")
fmt <- function(x) formatC(x, format = "f", digits = 1, big.mark = ",")
rows <- t1[, paste0(lab[as.character(outcome)], fifelse(scope == "whole day", ", whole day", ", hour 0"),
                    " & ", do.call(paste, c(lapply(.SD, fmt), sep = " & ")), " \\\\"), .SDcols = cols]
tex <- c("\\begin{tabular}{l rrrr rrrr}", "\\toprule",
         " & \\multicolumn{4}{c}{Treated} & \\multicolumn{4}{c}{Control} \\\\",
         "\\cmidrule(lr){2-5}\\cmidrule(lr){6-9}",
         " & \\multicolumn{2}{c}{Summer} & \\multicolumn{2}{c}{Off} & \\multicolumn{2}{c}{Summer} & \\multicolumn{2}{c}{Off} \\\\",
         " & Pre & Post & Pre & Post & Pre & Post & Pre & Post \\\\", "\\midrule", rows,
         "\\bottomrule", "\\end{tabular}")
writeLines(tex, file.path(path_tables, "table1_descriptives.tex"))

saveRDS(t1, file.path(path_audit, "table1.rds"))
options(width = 200)
print(t1[, c(list(outcome = outcome, scope = scope), lapply(.SD, round, 1)), .SDcols = cols])
