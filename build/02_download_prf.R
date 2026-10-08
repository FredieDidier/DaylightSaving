# =============================================================================
# 02_download_prf.R
#
# Downloads the PRF (Federal Highway Police) accident files, one per year,
# "agrupados por ocorrencia" (one row per accident), 2007-2025.
#
# Source page: https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/
# dados-abertos-da-prf (section "Acidentes"). The page links to Google Drive;
# the file ids, read off the page on 2026-10-08, are in build/manual/
# prf_files.csv. Each file is a zip holding one ';'-separated CSV.
#
# Output: prf/input/prf_<year>.zip under DROPBOX_ROOT (raw, untouched).
# Resumable: a year whose zip already exists and opens is skipped.
# =============================================================================

source(here::here("config", "config.R"))

path_prf_in <- file.path(DROPBOX_ROOT, "build", "prf", "input")
dir.create(path_prf_in, recursive = TRUE, showWarnings = FALSE)

files <- read.csv(file.path(path_manual, "prf_files.csv"), colClasses = "character")

zip_ok <- function(f) file.exists(f) &&
  !inherits(try(utils::unzip(f, list = TRUE), silent = TRUE), "try-error")

for (i in seq_len(nrow(files))) {
  y    <- files$year[i]
  dest <- file.path(path_prf_in, sprintf("prf_%s.zip", y))
  if (zip_ok(dest)) { message(y, ": already here"); next }
  # usercontent endpoint with confirm=t skips Drive's large-file warning page
  url <- sprintf("https://drive.usercontent.google.com/download?id=%s&export=download&confirm=t",
                 files$drive_id[i])
  status <- system2("curl", c("-sSL", "--retry", "3", "-o", shQuote(dest), shQuote(url)))
  if (status != 0 || !zip_ok(dest)) {
    unlink(dest)
    stop(y, ": download failed or file is not a zip")
  }
  message(y, ": ", round(file.size(dest) / 1e6, 1), " MB")
}
