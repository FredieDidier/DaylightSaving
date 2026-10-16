# =============================================================================
# 00_utils.R (analysis)
#
# Definitions every analysis script shares: the comparison groups, the season
# windows, the solar clock, and the UF x day panel builder. Sourced after
# config/config.R.
# =============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

# ── Groups ──────────────────────────────────────────────────────────────────
# Treated: DST in every season 2008/09-2018/19. Control: North and Northeast
# except BA and TO (one DST season each inside the window) and AC and AM
# (time-zone changes in 2008 and 2013).
TREATED <- c("RS", "SC", "PR", "SP", "RJ", "ES", "MG", "GO", "MT", "MS", "DF")
CONTROL <- c("RO", "RR", "PA", "AP", "MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE")
UF_CODE <- c(RO = 11, AC = 12, AM = 13, RR = 14, PA = 15, AP = 16, TO = 17,
             MA = 21, PI = 22, CE = 23, RN = 24, PB = 25, PE = 26, AL = 27,
             SE = 28, BA = 29, MG = 31, ES = 32, RJ = 33, SP = 35, PR = 41,
             SC = 42, RS = 43, MS = 50, MT = 51, GO = 52, DF = 53)
code_to_uf <- setNames(names(UF_CODE), UF_CODE)

# Mexico (26_mexico.R and the map in 29_figures.R). Units whose clock did not
# change with the Ley de los Husos Horarios (DOF 28/10/2022): Baja California
# (02), Quintana Roo (23) and Sonora (26), plus the border municipalities that
# keep DST on US dates, as listed in Art. 5, fraction I (INEGI state codes;
# names without accents). Chihuahua (08) changed time zone and is left out.
MX_CONTROL_STATES <- c("02", "23", "26")
MX_BORDER <- list(
  "05" = c("Acuna", "Allende", "Guerrero", "Hidalgo", "Jimenez", "Morelos", "Nava", "Ocampo",
           "Piedras Negras", "Villa Union", "Zaragoza"),
  "19" = c("Anahuac"),
  "28" = c("Nuevo Laredo", "Guerrero", "Mier", "Miguel Aleman", "Camargo", "Gustavo Diaz Ordaz",
           "Reynosa", "Rio Bravo", "Valle Hermoso", "Matamoros"))

# ── Seasons ─────────────────────────────────────────────────────────────────
# A season runs July-June and is named by its first year. Season s needs data
# through August of s + 1 (its off-season window), so the last usable season
# is the last consolidated SIM year minus one. First season: 2008/09, the first
# under the permanent rule of Decree 6,558/2008.
sim_years <- function(consolidated_only = TRUE) {
  f <- list.files(path_sim_out, pattern = "^sim_\\d{4}[.]parquet$", full.names = TRUE)
  y <- as.integer(sub(".*sim_(\\d{4}).*", "\\1", f))
  if (consolidated_only)
    y <- y[vapply(f, function(x) !any(read_parquet(x, col_select = "preliminary")$preliminary),
                  logical(1))]
  sort(y)
}
FIRST_SEASON <- 2008L
LAST_PRE     <- 2018L            # 2018/19, the last season with DST
season_range <- function() FIRST_SEASON:(max(sim_years()) - 1L)

# Windows inside each season:
#   win  Nov 15 - Feb 14, under DST on every day of every pre-2019 season
#        (2018/19 started Nov 4; the earliest end in the window was Feb 15, 2009)
#   off  Apr 1 - Aug 31, never DST
make_days <- function(seasons, ufs = c(TREATED, CONTROL)) {
  d <- CJ(uf = ufs, date = seq(as.IDate(sprintf("%d-07-01", min(seasons))),
                               as.IDate(sprintf("%d-06-30", max(seasons) + 1L)), by = "day"))
  d[, sy := year(date) - (month(date) < 7L)]
  md <- d[, month(date) * 100L + mday(date)]
  d[, window := fcase(md >= 1115L | md <= 214L, "win", md >= 401L & md <= 831L, "off")]
  d <- d[!is.na(window) & sy %in% seasons]
  d[, `:=`(treated = as.integer(uf %in% TREATED), win = as.integer(window == "win"),
           post = as.integer(sy > LAST_PRE))]
  d[, `:=`(tw = treated * win, t = sy - LAST_PRE)]
  d[, twp := tw * post]
  d[]
}

# ── Clock and sun ───────────────────────────────────────────────────────────
clock_min <- function(hhmm) {
  h <- suppressWarnings(as.integer(substr(hhmm, 1, 2)))
  m <- suppressWarnings(as.integer(substr(hhmm, 3, 4)))
  fifelse(nchar(hhmm) == 4L & h %between% c(0L, 23L) & m %between% c(0L, 59L),
          60L * h + m, NA_integer_)
}

# NOAA general solar position equations. Minutes after local STANDARD midnight
# at a point (lat, lon in degrees, east positive) whose standard UTC offset is
# offset_h hours. zenith 90.833 gives sunrise and sunset; 96 gives the start of
# morning and the end of evening civil twilight (sun 6 degrees below the
# horizon).
sun_times <- function(date, lat, lon, offset_h, zenith = 90.833) {
  doy <- as.integer(format(as.Date(date), "%j"))
  g   <- 2 * pi / 365 * (doy - 1 + 0.5)
  eqt <- 229.18 * (0.000075 + 0.001868 * cos(g) - 0.032077 * sin(g) -
                     0.014615 * cos(2 * g) - 0.040849 * sin(2 * g))
  dec <- 0.006918 - 0.399912 * cos(g) + 0.070257 * sin(g) - 0.006758 * cos(2 * g) +
    0.000907 * sin(2 * g) - 0.002697 * cos(3 * g) + 0.00148 * sin(3 * g)
  phi <- lat * pi / 180
  ha  <- acos(cos(zenith * pi / 180) / (cos(phi) * cos(dec)) - tan(phi) * tan(dec)) * 180 / pi
  list(sunrise = 720 - 4 * (lon + ha) - eqt + 60 * offset_h,
       sunset  = 720 - 4 * (lon - ha) - eqt + 60 * offset_h)
}

# Darkness index of the standard-time minutes [lo, hi): each minute of night
# counts 1, each minute of civil twilight 1/2, each minute of daylight 0.
# dawn and dusk are the civil twilight limits, rise and set the sunrise and
# sunset, all in minutes after standard midnight (sun_times). Returns minutes.
dark_minutes <- function(lo, hi, dawn, rise, set, dusk) {
  ov <- function(a, b) pmax(0, pmin(hi, b) - pmax(lo, a))
  ov(-1440, dawn) + ov(dusk, 2880) + 0.5 * (ov(dawn, rise) + ov(set, dusk))
}

# The pandemic. Dates from March 2020 to February 2022 are dropped together in
# the checks that leave the pandemic out; with July-June seasons, the strictest
# months (April-June 2020) fall in the off-season of 2019/20.
PANDEMIC <- as.IDate(c("2020-03-01", "2022-02-28"))
drop_pandemic <- function(d) d[!(date >= PANDEMIC[1] & date <= PANDEMIC[2])]

# Easter Sunday (anonymous Gregorian algorithm). Carnival Sunday is 49 days
# earlier; Decree 6,558/2008 moves the end of DST a week later when it would
# fall on Carnival Sunday.
easter_date <- function(y) {
  a <- y %% 19; b <- y %/% 100; c <- y %% 100; d <- b %/% 4; e <- b %% 4
  f <- (b + 8) %/% 25; g <- (b - f + 1) %/% 3; h <- (19 * a + b - d - g + 15) %% 30
  i <- c %/% 4; k <- c %% 4; l <- (32 + 2 * e + 2 * i - h - k) %% 7
  m <- (a + 11 * h + 22 * l) %/% 451; n <- h + l - 7 * m + 114
  as.IDate(sprintf("%d-%02d-%02d", y, n %/% 31, n %% 31 + 1))
}
# Carnival (Saturday to Ash Wednesday) and the year-end holidays (24 December
# to 1 January), the summer-window days on which travel is least like the rest.
holiday_days <- function(years) {
  car <- unlist(lapply(years, function(y) as.integer(easter_date(y) - 50:46)))
  ye  <- unlist(lapply(years, function(y) as.integer(c(as.IDate(sprintf("%d-12-%02d", y, 24:31)),
                                                       as.IDate(sprintf("%d-01-01", y + 1))))))
  as.IDate(sort(unique(c(car, ye))))
}

# ── Panel ───────────────────────────────────────────────────────────────────
# UF x day counts of one outcome in one sun bin, zeros filled over `days`.
# side = "set" bins on clock - sunset_std, "rise" on clock - sunrise_std.
EVENTS_FILE <- file.path(path_audit, "events_sun_bins.parquet")
# Argument names must not coincide with column names of `ev` (data.table would
# resolve them to the columns and the filter would always be TRUE), so the
# selection vector is built outside the brackets.
make_panel <- function(ev, days, outc, b, side = "set") {
  col <- if (side == "set") "bin_set" else "bin_rise"
  sel <- ev[["outcome"]] == outc & ev[[col]] == b
  stopifnot(any(sel))
  y <- ev[sel, .(y = sum(w)), by = .(uf, date)]
  p <- y[days, on = .(uf, date)]
  p[is.na(y), y := 0]
  p[]
}

# PRF accidents carry the municipality's name, not its code. Names are matched
# to the IBGE seat name within the state; the names that differ (renamed
# municipalities, spelling variants) are typed in build/manual/
# prf_municipio_alias.csv, without which ~0.4% of PRF accidents would go
# unmatched. Returns `prf` with code6 (NA when unmatched).
prf_code6 <- function(prf, geo) {
  norm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
  seats <- geo[, .(key = paste(uf, norm(name)), code6)]
  alias <- fread(file.path(path_manual, "prf_municipio_alias.csv"), encoding = "UTF-8")
  alias <- alias[, .(key = paste(uf, norm(municipio_prf)), code6)]
  keys <- rbind(unique(seats, by = "key"), alias[!key %in% seats$key])
  stopifnot(!anyDuplicated(keys$key), all(alias$code6 %in% geo$code6))
  out <- keys[copy(prf)[, key := paste(uf, norm(municipio))], on = "key"]
  out[, key := NULL]
  out[]
}

FE <- "| uf^window + uf^sy + date"

# Permutation p-value, two-sided: the observed assignment counts as one of the
# possible draws, so p = (1 + #{|b_perm| >= |b|}) / (1 + N) and the smallest
# attainable value is 1 / (N + 1); mean(abs(perm) >= abs(b)) could return 0,
# which 999 draws cannot support.
perm_pvalue <- function(perm, b) (1 + sum(abs(perm) >= abs(b))) / (1 + length(perm))

# The permutation tests compare t-statistics, not coefficients: MacKinnon and
# Webb (2020, J. Econometrics) show that a test on the coefficient can be
# unreliable when clusters are heterogeneous, and states differ widely in size.
# fit_bs returns the coefficient on `v` and its standard error clustered by
# `cl`; a difference of two separately fitted coefficients is studentized by
# the square root of the sum of their squared standard errors (t_diff). The
# actual and every permuted assignment go through the same statistic.
fit_bs <- function(f, data, v, cl = ~uf) {
  m <- fixest::fepois(f, data = data, cluster = cl, notes = FALSE)
  c(b = unname(coef(m)[v]), se = unname(fixest::se(m)[v]))
}
t_stat <- function(bs) bs[["b"]] / bs[["se"]]
t_diff <- function(bs1, bs2) (bs1[["b"]] - bs2[["b"]]) / sqrt(bs1[["se"]]^2 + bs2[["se"]]^2)

TRAFFIC <- c("SIM transport deaths, on road", "PRF deaths", "PRF injury accidents")

# ── Figures: house style ────────────────────────────────────────────────────
# No title, subtitle
# or caption (the caption lives in LaTeX); legend at the bottom with no title;
# saved at the size it is PRINTED at, so type is never scaled: a 12pt article
# with 1in margins has a 6.5in text block and every figure goes in at
# \textwidth. PDF through cairo (en dash, minus sign and accents render) plus a
# 300 dpi PNG, white background.
#
# Palette, validated with the dataviz skill's validate_palette.js (light mode,
# CVD and normal-vision separation pass for every pair used together):
#   pre / post abolition ............... red  #C0392B / blue #2471A3
#   switched hour / other hours ........ red  #C0392B / grey #7B7D7D (grey is
#                                        context on purpose)
#   dawn / dusk ........................ amber #B9770E / blue #2471A3
# Every series told apart by colour also gets its own shape or line type, so a
# grey-scale print still separates them.
PAL <- c(red = "#C0392B", blue = "#2471A3", grey = "#7B7D7D", amber = "#B9770E",
         ink = "#2C3E50")
FIG_WIDTH <- 6.5

theme_paper <- function(base = 10) {
  ggplot2::theme_bw(base_size = base) +
    ggplot2::theme(
      legend.position    = "bottom",
      legend.title       = ggplot2::element_blank(),
      legend.text        = ggplot2::element_text(size = base),
      legend.key.width   = ggplot2::unit(0.9, "cm"),
      legend.margin      = ggplot2::margin(t = 0, b = 0),
      legend.box.spacing = ggplot2::unit(5, "pt"),
      panel.grid.minor   = ggplot2::element_blank(),
      panel.grid.major   = ggplot2::element_line(colour = "grey92"),
      panel.border       = ggplot2::element_rect(colour = "grey70"),
      axis.text          = ggplot2::element_text(size = base - 1, colour = "grey20"),
      axis.title         = ggplot2::element_text(size = base),
      strip.text         = ggplot2::element_text(size = base),
      strip.background   = ggplot2::element_rect(fill = "grey94", colour = NA),
      plot.title         = ggplot2::element_blank(),
      plot.subtitle      = ggplot2::element_blank(),
      plot.caption       = ggplot2::element_blank(),
      plot.margin        = ggplot2::margin(3, 8, 3, 3)
    )
}

# A label wider than its panel is clipped in the PDF, and the PNG does not show
# it (different font metrics). Measure on the PDF device and warn; never stop.
check_fig_labels <- function(plot, name, width, height) {
  tryCatch({
    f  <- tempfile(fileext = ".pdf")
    d0 <- grDevices::dev.cur()
    grDevices::cairo_pdf(f, width = width, height = height)
    on.exit({ if (!identical(grDevices::dev.cur(), d0)) grDevices::dev.off(); unlink(f) },
            add = TRUE)
    g <- ggplot2::ggplotGrob(plot)
    grid::grid.draw(g)
    panel <- width - sum(as.numeric(grid::convertWidth(g$widths, "in")))
    xlab <- plot$labels$x
    if (!is.null(xlab) && nzchar(xlab)) {
      w <- as.numeric(grid::convertWidth(
        grid::grobWidth(grid::textGrob(xlab, gp = grid::gpar(fontsize = 10))), "in"))
      if (w > width - 0.6)
        warning(sprintf("%s: x-axis title is %.2f in wide; it may be clipped.", name, w),
                call. = FALSE)
    }
  }, error = function(e) invisible(NULL))
}

save_fig <- function(plot, name, width = FIG_WIDTH, height = 4.2, dir = path_graphs) {
  check_fig_labels(plot, name, width, height)
  ggplot2::ggsave(file.path(dir, paste0(name, ".pdf")), plot,
                  width = width, height = height, device = grDevices::cairo_pdf, bg = "white")
  # ragg renders the Unicode minus sign and en dash; the default png device
  # draws them as "...".
  ggplot2::ggsave(file.path(dir, paste0(name, ".png")), plot,
                  width = width, height = height, dpi = 300, bg = "white", device = ragg::agg_png)
  cat(sprintf("  saved %s (%.1f x %.1f in)\n", name, width, height))
}

# Labels. Clock hours in a.m./p.m.; season "2008/09".
#
# Non-ASCII characters (en dash, minus sign, times sign) are written ONLY as
# \u escapes. R on this machine runs in a non-UTF-8 locale and reads a literal
# non-ASCII character in a source file with the wrong encoding, which renders
# as "..." on both devices. A \u escape is plain ASCII in the file and becomes
# a UTF-8 string when parsed.
#
# A \u escape is not enough when R starts in the C locale (LANG unset, as in a
# non-login shell): it then cannot represent the character and the label
# prints as "..". Force a UTF-8 character type so figures do not depend on the
# shell that runs the script.
if (!isTRUE(l10n_info()$`UTF-8`))
  invisible(suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8")))
hour_ampm <- function(h) {
  h <- h %% 24
  ifelse(h == 0, "midnight", ifelse(h == 12, "noon",
         ifelse(h < 12, paste(h, "a.m."), paste(h - 12, "p.m."))))
}
season_lab <- function(s) sprintf("%d/%02d", s, (s + 1) %% 100)
# Axis numbers with a true minus sign.
num_lab <- function(x) {
  s <- format(abs(x), trim = TRUE, drop0trailing = TRUE)
  out <- ifelse(x < 0, paste0("\u2212", s), s)
  out[is.na(x)] <- NA_character_
  out
}
signed_lab <- function(x) ifelse(x == 0, "0", ifelse(x > 0, paste0("+", x), paste0("\u2212", abs(x))))
# Outcome names: one object, one name, in every figure, table and sentence.
# Named for what they count, never for the source: death certificates cover
# every public road, the federal highway police only its own highways, so
# "Federal highway" is what separates the two death counts.
OUTCOME_LAB <- c("SIM transport deaths, on road" = "Road deaths",
                 "PRF deaths"                    = "Federal highway deaths",
                 "PRF injury accidents"          = "Federal highway injury crashes",
                 "SIM assault deaths, on road"   = "Assault deaths")

# Outcome headers. Where a figure has one panel per outcome, the outcome name
# sits above its panel(s) in bold, flush left, with no box; grey strips are
# kept for the second dimension (evening/morning, restriction). Outcome names
# never go in a right-hand strip, which reads as a second y axis.
theme_outcome_strip <- function(base = 10) {
  ggplot2::theme(strip.text       = ggplot2::element_text(size = base, face = "bold", hjust = 0,
                                                          margin = ggplot2::margin(4, 0, 3, 0)),
                 strip.background = ggplot2::element_blank())
}

# Several outcomes, each a row of panels with a shared y scale inside the row:
# one ggplot per row, stacked with patchwork. Row titles carry the outcome;
# the column strips and the x axis are drawn once (top and bottom row), the
# legend once (bottom row), and the y-axis titles are collected into one.
# Guides are not collected: patchwork 1.3.0 under ggplot2 4.0 cannot take
# `& theme()` and would put a collected legend on the right.
stack_rows <- function(rows, base = 10) {
  n <- length(rows)
  rows <- lapply(seq_len(n), function(i) {
    g <- rows[[i]] + ggplot2::theme(
      plot.title = ggplot2::element_text(size = base, face = "bold", hjust = 0,
                                         margin = ggplot2::margin(2, 0, 3, 0)),
      plot.title.position = "panel")
    if (i > 1) g <- g + ggplot2::theme(strip.text = ggplot2::element_blank(),
                                       strip.background = ggplot2::element_blank())
    if (i < n) g <- g + ggplot2::labs(x = NULL) +
      ggplot2::theme(axis.text.x = ggplot2::element_blank(), axis.ticks.x = ggplot2::element_blank(),
                     legend.position = "none")
    g
  })
  patchwork::wrap_plots(rows, ncol = 1) + patchwork::plot_layout(axis_titles = "collect")
}

# Seasons after abolition are shaded and labelled once, in the first panel.
POST_LABEL <- "Without DST"
