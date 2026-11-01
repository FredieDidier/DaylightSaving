# =============================================================================
# 01_dst_calendar.R
#
# Turns the hand-coded legal calendar in build/manual/ into the treatment
# objects every later script reads:
#
#   calendar/output/dst_uf_season.parquet   UF x season (1985/86-2018/19)
#   calendar/output/dst_uf_day.parquet      UF x calendar day, 1985-2026
#   horario_verao/TABELA_ESTADOS.md         the grid, for reading and for a
#                                           future paper table
#
# Inputs (versioned, typed from the decrees on planalto.gov.br; the texts are
# kept in horario_verao/fontes_legais/):
#   hv_temporadas.csv   one row per season: dates, states, legal acts
#   hv_excecoes.csv     states that left in the middle of a season (2000/01)
#
# Timing convention: every decree says DST starts and ends at 00:00 local
# time. A day is coded dst = 1 when the clock was advanced for the whole day,
# i.e. start <= date < end. The end date itself is standard time.
#
# The script also checks the 2008-2018 dates against the permanent rule of
# Decree 6,558/2008 (3rd Sunday of October to 3rd Sunday of February, moved one
# week when the end falls on Carnival Sunday; from 2018 the start is the 1st
# Sunday of November, Decree 9,242/2017). A mismatch stops the build.
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

seasons    <- fread(file.path(path_manual, "hv_temporadas.csv"),
                    colClasses = list(character = c("temporada", "ufs")))
exceptions <- fread(file.path(path_manual, "hv_excecoes.csv"))
seasons[, `:=`(inicio = as.IDate(inicio), fim = as.IDate(fim))]
exceptions[, `:=`(inicio_uf = as.IDate(inicio_uf), fim_uf = as.IDate(fim_uf))]

# ── 1. Sanity checks on the season table ────────────────────────────────────
stopifnot(
  !anyDuplicated(seasons$temporada),
  all(seasons$fim > seasons$inicio),
  all(seasons$inicio[-1] > seasons$fim[-nrow(seasons)])   # no overlap
)
listed <- unique(unlist(strsplit(seasons[ufs != "TODAS", ufs], " ")))
stopifnot(all(listed %in% UFS))

# Gauss/Meeus algorithm for Easter Sunday; Carnival Sunday is 49 days earlier.
easter <- function(y) {
  a <- y %% 19; b <- y %/% 100; c <- y %% 100
  d <- b %/% 4; e <- b %% 4; f <- (b + 8) %/% 25; g <- (b - f + 1) %/% 3
  h <- (19 * a + b - d - g + 15) %% 30
  i <- c %/% 4; k <- c %% 4
  l <- (32 + 2 * e + 2 * i - h - k) %% 7
  m <- (a + 11 * h + 22 * l) %/% 451
  month <- (h + l - 7 * m + 114) %/% 31
  day   <- ((h + l - 7 * m + 114) %% 31) + 1
  as.IDate(sprintf("%d-%02d-%02d", y, month, day))
}
nth_sunday <- function(y, m, n) {
  first <- as.IDate(sprintf("%d-%02d-01", y, m))
  offset <- (7 - as.POSIXlt(first)$wday) %% 7      # days to the first Sunday
  first + offset + 7L * (n - 1L)
}

rule <- seasons[as.integer(substr(temporada, 1, 4)) >= 2008]
rule[, y := as.integer(substr(temporada, 1, 4))]
rule[, start_rule := fifelse(y >= 2018, nth_sunday(y, 11, 1),
                             nth_sunday(y, 10, 3))]
rule[, end_rule := nth_sunday(y + 1L, 2, 3)]
rule[end_rule == easter(y + 1L) - 49L, end_rule := end_rule + 7L]
bad <- rule[inicio != start_rule | fim != end_rule]
if (nrow(bad)) {
  print(bad[, .(temporada, inicio, start_rule, fim, end_rule)])
  stop("Season dates disagree with the Decree 6,558/2008 rule.")
}

# ── 2. UF x season ──────────────────────────────────────────────────────────
uf_season <- CJ(temporada = seasons$temporada, uf = UFS)
uf_season <- seasons[, .(temporada, inicio, fim, ufs, atos, verificacao)][
  uf_season, on = "temporada"]
uf_season[, in_list := ufs == "TODAS" |
            mapply(function(u, l) u %in% strsplit(l, " ")[[1]], uf, ufs)]
uf_season[, `:=`(inicio_uf = fifelse(in_list, inicio, as.IDate(NA)),
                 fim_uf    = fifelse(in_list, fim,    as.IDate(NA)))]

# Mid-season exits override the full-season dates.
uf_season[exceptions, on = .(temporada, uf),
          `:=`(inicio_uf = i.inicio_uf, fim_uf = i.fim_uf)]
uf_season[, dst_days := fifelse(is.na(inicio_uf), 0L,
                                as.integer(fim_uf - inicio_uf))]
uf_season[, status := fcase(dst_days == 0L, "out",
                            dst_days < as.integer(fim - inicio), "partial",
                            default = "in")]
uf_season <- uf_season[, .(temporada, uf, status, dst_days, inicio_uf, fim_uf,
                           season_start = inicio, season_end = fim, atos,
                           verificacao)]
setorder(uf_season, temporada, uf)

# ── 3. UF x day ─────────────────────────────────────────────────────────────
days   <- seq(as.IDate("1985-01-01"), as.IDate("2026-12-31"), by = "day")
uf_day <- CJ(uf = UFS, date = days)
uf_day[, dst := 0L]
spells <- uf_season[status != "out", .(uf, start = inicio_uf, end = fim_uf - 1L)]
uf_day[spells, on = .(uf, date >= start, date <= end), dst := 1L]

# The calendar season a day belongs to (Jul-Jun), whether or not DST applied.
uf_day[, season_year := year(date) - (month(date) < 7L)]
uf_day[, temporada := sprintf("%d/%02d", season_year, (season_year + 1L) %% 100L)]
uf_day[, season_year := NULL]

# Cross-check: summed DST days per UF-season must equal dst_days.
chk <- uf_day[, .(n = sum(dst)), by = .(uf, temporada)][
  uf_season, on = .(uf, temporada)]
stopifnot(all(chk$n == chk$dst_days))

write_parquet(uf_season, file.path(path_calendar_out, "dst_uf_season.parquet"))
write_parquet(uf_day,    file.path(path_calendar_out, "dst_uf_day.parquet"))

# ── 4. Markdown grid ────────────────────────────────────────────────────────
# Rows are UFs grouped by region; columns are seasons. Symbols:
#   ● whole season   ◐ part of the season   · no DST
sym  <- c(`in` = "●", partial = "◐", out = "·")
grid <- dcast(uf_season, uf ~ temporada, value.var = "status")
grid <- grid[match(UFS, uf)]
cols <- setdiff(names(grid), "uf")
short <- substr(cols, 3, 4)                         # "1985/86" -> "85"

md <- c(
  "# Daylight saving time by state and season, 1985/86–2018/19",
  "",
  "Generated by `build/01_dst_calendar.R` from `build/manual/` — **do not edit by hand**.",
  "Source: decrees at planalto.gov.br (texts in `horario_verao/fontes_legais/`).",
  "",
  "● whole season · ◐ part of the season · `·` no daylight saving time.",
  "Column = first year of the season (85 = 1985/86). The 2019/20 season did not happen (Decree 9.772/2019).",
  "",
  paste0("| State | ", paste(short, collapse = " | "), " |"),
  paste0("|---|", paste(rep(":-:", length(cols)), collapse = "|"), "|"),
  vapply(seq_len(nrow(grid)), function(i)
    paste0("| ", grid$uf[i], " | ",
           paste(sym[unlist(grid[i, ..cols])], collapse = " | "), " |"),
    character(1)),
  "",
  "## Number of states with daylight saving time in each season",
  "",
  "| Season | Start | End | States (whole) | States (part) | Legal acts |",
  "|---|---|---|--:|--:|---|",
  uf_season[, .(start = season_start[1], end = season_end[1],
                n_in = sum(status == "in"), n_part = sum(status == "partial"),
                acts = atos[1]), by = temporada][
    , sprintf("| %s | %s | %s | %d | %d | %s |", temporada,
              format(start, "%Y-%m-%d"), format(end, "%Y-%m-%d"),
              n_in, n_part, gsub("Dec ", "Decree ", acts, fixed = TRUE))],
  ""
)
writeLines(md, here::here("horario_verao", "TABELA_ESTADOS.md"))

cat(sprintf("UF x season: %d rows | UF x day: %d rows | DST UF-days: %d\n",
            nrow(uf_season), nrow(uf_day), uf_day[, sum(dst)]))
