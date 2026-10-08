# =============================================================================
# 03_clean_prf.R
#
# Stacks the PRF accident files (one row per accident) into one harmonised
# table, 2007-2025.
#
# What changes across years, and how it is handled:
#   - date format: dd/mm/yyyy (2007-2011), yyyy-mm-dd (2012-2015, 2017+),
#     dd/mm/yy (2016). Parsed by pattern, then checked against the file year.
#   - encoding: latin1 in the older files, UTF-8 in the re-issued ones. Read
#     as latin1 when the bytes are not valid UTF-8.
#   - duplicated ids: in some years one accident appears on several rows that
#     differ only in a descriptive field (e.g. weather). Counts of people are
#     identical across the copies, so one row per id is kept.
#   - fase_dia labels vary in case ("Plena noite" / "Plena Noite"); lower-cased.
#   - latitude/longitude exist from 2017 only (decimal comma).
#
# Output: prf/output/prf_accidents.parquet under DROPBOX_ROOT.
# Clock time ("horario") is the local legal time written on the report.
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

path_prf_in  <- file.path(DROPBOX_ROOT, "build", "prf", "input")
path_prf_out <- file.path(DROPBOX_ROOT, "build", "prf", "output")
dir.create(path_prf_out, recursive = TRUE, showWarnings = FALSE)

num <- function(x) suppressWarnings(as.numeric(sub(",", ".", x, fixed = TRUE)))

parse_date <- function(x) {
  out <- as.IDate(rep(NA_character_, length(x)))
  iso <- grepl("^\\d{4}-\\d{2}-\\d{2}$", x)
  dmy <- grepl("^\\d{2}/\\d{2}/\\d{4}$", x)
  dmy2 <- grepl("^\\d{2}/\\d{2}/\\d{2}$", x)
  out[iso]  <- as.IDate(x[iso])
  out[dmy]  <- as.IDate(x[dmy],  format = "%d/%m/%Y")
  out[dmy2] <- as.IDate(x[dmy2], format = "%d/%m/%y")
  out
}

read_year <- function(y) {
  zf  <- file.path(path_prf_in, sprintf("prf_%d.zip", y))
  csv <- utils::unzip(zf, list = TRUE)$Name[1]
  tmp <- file.path(tempdir(), csv)
  utils::unzip(zf, files = csv, exdir = tempdir(), overwrite = TRUE)
  raw <- readBin(tmp, "raw", n = 2e6)
  enc <- if (validUTF8(rawToChar(raw[raw != as.raw(0)]))) "UTF-8" else "Latin-1"
  d <- fread(tmp, sep = ";", encoding = enc, colClasses = "character",
             na.strings = c("", "NA", "(null)"))
  unlink(tmp)
  setnames(d, tolower(names(d)))
  has_ll <- all(c("latitude", "longitude") %in% names(d))
  d[, .(year_file = y,
        id        = id,
        date      = parse_date(data_inversa),
        hhmm      = horario,
        uf        = toupper(trimws(uf)),
        br        = br,
        km        = num(km),
        municipio = municipio,
        fase_dia  = tolower(trimws(fase_dia)),
        tipo_acidente, causa_acidente, condicao_metereologica,
        classificacao = tolower(trimws(classificacao_acidente)),
        pessoas   = as.integer(pessoas),
        mortos    = as.integer(mortos),
        feridos_graves = as.integer(feridos_graves),
        feridos   = as.integer(feridos),
        veiculos  = as.integer(veiculos),
        lat = if (has_ll) num(latitude) else NA_real_,
        lon = if (has_ll) num(longitude) else NA_real_)]
}

prf <- rbindlist(lapply(2007:2025, read_year))

# ── Checks and clean-up ─────────────────────────────────────────────────────
n_raw <- nrow(prf)
prf <- unique(prf, by = c("year_file", "id"))
n_dedup <- nrow(prf)

prf[, hour := suppressWarnings(as.integer(substr(hhmm, 1, 2)))]
prf[, minute := suppressWarnings(as.integer(substr(hhmm, 4, 5)))]
prf[!(hour %between% c(0L, 23L)), hour := NA_integer_]
prf[is.na(hour) | !(minute %between% c(0L, 59L)), minute := NA_integer_]

bad_year <- prf[!is.na(date), mean(year(date) != year_file)]
stopifnot(prf[, mean(is.na(date))] < 0.001, bad_year < 0.001)
prf <- prf[!is.na(date) & year(date) == year_file]
print(prf[!uf %in% UFS, .N, by = .(uf, year_file)])
stopifnot(prf[, mean(!uf %in% UFS)] < 0.001)
prf <- prf[uf %in% UFS]

prf[, hhmm := NULL]
setorder(prf, date, id)
write_parquet(prf, file.path(path_prf_out, "prf_accidents.parquet"))

cat(sprintf("rows read %d | after dedup %d | kept %d\n", n_raw, n_dedup, nrow(prf)))
print(prf[, .(accidents = .N, deaths = sum(mortos, na.rm = TRUE),
              miss_hour = round(100 * mean(is.na(hour)), 2),
              miss_fase = round(100 * mean(is.na(fase_dia)), 2),
              has_latlon = round(100 * mean(!is.na(lat)), 1)), by = year_file])
print(prf[, .N, by = fase_dia][order(-N)])
