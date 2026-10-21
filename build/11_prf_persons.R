# =============================================================================
# 11_prf_persons.R
#
# Downloads and cleans the PRF (Federal Highway Police) accident files
# "agrupados por pessoa": one row per person involved in an accident, with the
# person's role, physical state, age and sex, 2007-2025. They give the sex and
# age of the dead on federal highways, which the accident files of 02-03 do not.
#
# Source page: https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/
# dados-abertos-da-prf (section "Acidentes", "Agrupados por pessoa"; not the
# "Todas as causas e tipos de acidentes" files, which start in 2017). The
# Google Drive ids, read off the page on 2026-10-16, are in build/manual/
# prf_person_files.csv.
#
# What changes across years, and how it is handled:
#   - separator: ',' up to 2016, ';' afterwards (fread detects it);
#   - encoding: latin1 or UTF-8, detected as in 03;
#   - labels: physical state "Morto" (to 2016) / "Obito" (2017+), "Ferido
#     Leve" / "Lesoes Leves", and so on; sex "Masculino" / "Feminino", but
#     "M" / "F" / "I" in 2016, with "Invalido" / "Nao Informado" / "Ignorado"
#     for unknown. Labels are transliterated to ASCII letters, lower-cased and
#     mapped to a few values;
#   - from 2017 the files also list witnesses and rows with no role;
#   - age: blank when unknown up to 2016 (11-12% of the dead), but 0 from
#     2017 (5-6% of the dead are aged 0 from 2017, against 0.3% before). Age
#     0 is therefore set to unknown in every year; infants are a negligible
#     share of the dead on federal highways.
# Persons are matched to accidents by (year of the file, id). The dead per
# accident must add up to `mortos` of prf_accidents.parquet (03), which counts
# people dead at the scene; the script stops if they do not. The 2007 and 2008
# person files also list 326 and 34 dead in accidents that the accident files
# of those years do not carry; they never enter the analysis, which starts from
# the accidents, and from 2009 on such cases must stay below 0.1%.
#
# Output: prf/output/prf_persons.parquet under DROPBOX_ROOT, with year_file,
#   id, pesid, role, state (dead / serious / light / unhurt / unknown), age
#   (1-110, else NA) and sex (male / female, else NA).
# The downloaded zips are deleted once the output is written and checked.
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

path_in  <- file.path(DROPBOX_ROOT, "build", "prf", "input", "persons")
path_out <- file.path(DROPBOX_ROOT, "build", "prf", "output")
dir.create(path_in, recursive = TRUE, showWarnings = FALSE)
dir.create(path_out, recursive = TRUE, showWarnings = FALSE)

files <- read.csv(file.path(path_manual, "prf_person_files.csv"), colClasses = "character")
zip_ok <- function(f) file.exists(f) &&
  !inherits(try(utils::unzip(f, list = TRUE), silent = TRUE), "try-error")

# ── Download (resumable) ────────────────────────────────────────────────────
for (i in seq_len(nrow(files))) {
  dest <- file.path(path_in, sprintf("prf_persons_%s.zip", files$year[i]))
  if (zip_ok(dest)) next
  url <- sprintf("https://drive.usercontent.google.com/download?id=%s&export=download&confirm=t",
                 files$drive_id[i])
  status <- system2("curl", c("-sSL", "--retry", "3", "-o", shQuote(dest), shQuote(url)))
  if (status != 0 || !zip_ok(dest)) {
    unlink(dest)
    stop(files$year[i], ": download failed or file is not a zip")
  }
  message(files$year[i], ": ", round(file.size(dest) / 1e6, 1), " MB")
}

# ── Read and harmonise ──────────────────────────────────────────────────────
ascii <- function(x) trimws(gsub("[^a-z ]", "", tolower(iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT"))))

read_year <- function(y) {
  zf  <- file.path(path_in, sprintf("prf_persons_%d.zip", y))
  csv <- utils::unzip(zf, list = TRUE)$Name[1]
  tmp <- file.path(tempdir(), basename(csv))
  utils::unzip(zf, files = csv, exdir = tempdir(), overwrite = TRUE, junkpaths = TRUE)
  raw <- readBin(tmp, "raw", n = 2e6)
  enc <- if (validUTF8(rawToChar(raw[raw != as.raw(0)]))) "UTF-8" else "Latin-1"
  d <- fread(tmp, encoding = enc, colClasses = "character", na.strings = c("", "NA", "(null)"))
  unlink(tmp)
  setnames(d, tolower(names(d)))
  need <- c("id", "pesid", "data_inversa", "tipo_envolvido", "estado_fisico", "idade", "sexo")
  if (!all(need %in% names(d)))
    stop(y, ": not a person-level file; missing ", paste(setdiff(need, names(d)), collapse = ", "))
  d <- d[, ..need]
  # Text fields come in the file's encoding; fread marks them, iconv needs UTF-8.
  for (v in c("tipo_envolvido", "estado_fisico", "sexo")) set(d, j = v, value = enc2utf8(d[[v]]))
  st <- ascii(d$estado_fisico)
  sx <- ascii(d$sexo)
  age <- suppressWarnings(as.numeric(d$idade))
  d[, .(year_file = y, id, pesid,
        date  = data_inversa,
        role  = ascii(tipo_envolvido),
        state = fcase(grepl("morto|obito", st), "dead",
                      grepl("grave", st), "serious",
                      grepl("leve", st), "light",
                      grepl("ileso", st), "unhurt",
                      default = "unknown"),
        age   = fifelse(!is.na(age) & age >= 1 & age <= 110, as.integer(age), NA_integer_),
        sex   = fcase(sx %in% c("masculino", "m"), "male", sx %in% c("feminino", "f"), "female"))]
}

per <- rbindlist(lapply(as.integer(files$year), read_year))

# ── Checks ──────────────────────────────────────────────────────────────────
# Dates: the year of the file (formats vary, as in 03; only the year is used).
yr <- suppressWarnings(as.integer(ifelse(grepl("^\\d{4}", per$date), substr(per$date, 1, 4),
                       ifelse(grepl("/\\d{4}$", per$date), substring(per$date, nchar(per$date) - 3),
                              2000L + as.integer(substring(per$date, nchar(per$date) - 1))))))
stopifnot(mean(yr == per$year_file, na.rm = TRUE) > 0.999)
per[, date := NULL]
n_raw <- nrow(per)
per <- unique(per, by = c("year_file", "id", "pesid"))

# The dead must add up to `mortos` of the accident file, accident by accident.
acc <- as.data.table(read_parquet(file.path(path_out, "prf_accidents.parquet"),
                                  col_select = c("year_file", "id", "mortos")))
dead <- per[state == "dead", .(dead = .N), by = .(year_file, id)]
chk <- dead[acc, on = .(year_file, id)][is.na(dead), dead := 0L]
by_year <- chk[, .(mortos = sum(mortos, na.rm = TRUE), dead_persons = sum(dead),
                   accidents_differing = sum(dead != fcoalesce(mortos, 0L))), by = year_file]
print(by_year)
stopifnot(by_year[, all(abs(dead_persons - mortos) <= 0.001 * mortos)])
orphans <- dead[!acc, on = .(year_file, id)][, .(orphans = sum(dead)), by = year_file]
cat("dead persons with no accident in prf_accidents, by year:\n"); print(orphans)
stopifnot(orphans[year_file >= 2009L, sum(orphans)] <= 0.001 * dead[year_file >= 2009L, sum(dead)])

setorder(per, year_file, id, pesid)
write_parquet(per, file.path(path_out, "prf_persons.parquet"))
cat(sprintf("rows read %d | kept %d\n", n_raw, nrow(per)))
print(per[state == "dead", .(dead = .N, age_missing_pct = round(100 * mean(is.na(age)), 1),
                             sex_missing_pct = round(100 * mean(is.na(sex)), 1),
                             female_pct = round(100 * mean(sex == "female", na.rm = TRUE), 1)),
          by = year_file])
print(per[, .N, by = .(role)][order(-N)])

unlink(path_in, recursive = TRUE)
