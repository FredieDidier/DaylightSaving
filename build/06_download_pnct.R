# =============================================================================
# 06_download_pnct.R
#
# Downloads the hourly traffic volume of DNIT's continuous count stations
# (PNCT, Plano Nacional de Contagem de Trafego), 2014-2019 and 2021-2025
# (2020 is not published).
#
# Source: the PNCT portal, https://servicos.dnit.gov.br/dadospnct (page
# "Acesse os Dados"). Its API is undocumented; the routes were read off the
# page's JavaScript on 2026-10-09 (horario_verao/VIABILIDADE.md, section 12):
#   GET /dadospnct-api/api/v1/coletaContinua/anos
#   GET /dadospnct-api/api/v1/coletasFiltros/uf | /br?uf=
#   GET /dadospnct-api/api/v1/coletaContinua/postocontagem/vh/csv?uf=&br=&ano=
#       (Accept: application/zip) -> one zip with, per station,
#       <br>_<uf>_km<km>_<year>.csv (hourly volume by direction and vehicle
#       class), plus _vmdm.csv and _vtd.csv summaries.
# A request for all UFs at once times out at the gateway (502 after 60 s), so
# the loop goes UF by UF, and falls back to BR by BR when a UF times out.
#
# Output: pnct/input/vh_<year>_<uf>[_<br>].zip under DROPBOX_ROOT (raw).
# Resumable: a file that already exists and opens as a zip is skipped. A
# UF-year with no station returns 204 (no content) and is logged, not fatal.
# =============================================================================

source(here::here("config", "config.R"))

API <- "https://servicos.dnit.gov.br/dadospnct-api/api/v1"
path_pnct_in <- file.path(DROPBOX_ROOT, "build", "pnct", "input")
dir.create(path_pnct_in, recursive = TRUE, showWarnings = FALSE)

get_json <- function(route) jsonlite::fromJSON(
  paste(system2("curl", c("-sSL", "--retry", "3", "--max-time", "120",
                          shQuote(paste0(API, route))), stdout = TRUE), collapse = ""))

zip_ok <- function(f) file.exists(f) && file.size(f) > 0 &&
  !inherits(try(utils::unzip(f, list = TRUE), silent = TRUE), "try-error")

fetch <- function(dest, uf, br, year) {
  if (zip_ok(dest)) return("here")
  url <- sprintf("%s/coletaContinua/postocontagem/vh/csv?uf=%s&br=%s&ano=%d", API, uf, br, year)
  for (attempt in 1:3) {
    code <- system2("curl", c("-sSL", "--max-time", "300", "-H", shQuote("Accept: application/zip"),
                              "-o", shQuote(dest), "-w", shQuote("%{http_code}"), shQuote(url)),
                    stdout = TRUE)
    if (zip_ok(dest)) return("ok")
    unlink(dest)
    if (code %in% c("200", "204")) return("empty")   # no station that UF-year
    if (code %in% c("502", "504")) return("failed")   # gateway timeout: split by BR
    Sys.sleep(5 * attempt)
  }
  "failed"
}

years <- sort(get_json("/coletaContinua/anos?uf=&br=")$anos)
ufs   <- get_json("/coletasFiltros/uf")
ufs   <- if (is.list(ufs)) unlist(ufs, use.names = FALSE) else ufs
stopifnot(length(years) > 0, length(ufs) > 0)
message("years: ", paste(years, collapse = " "), " | UFs: ", length(ufs))

log <- list()
for (y in years) for (u in ufs) {
  dest <- file.path(path_pnct_in, sprintf("vh_%d_%s.zip", y, u))
  st <- fetch(dest, u, "", y)
  if (st == "failed") {
    # UF too large for the gateway: one request per BR.
    brs <- unlist(get_json(sprintf("/coletasFiltros/br?uf=%s", u)), use.names = FALSE)
    st_br <- vapply(brs, function(b)
      fetch(file.path(path_pnct_in, sprintf("vh_%d_%s_%s.zip", y, u, b)), u, b, y), character(1))
    log[[length(log) + 1]] <- data.frame(year = y, uf = u, br = brs, status = st_br)
    st <- sprintf("split by BR (%d ok, %d failed)", sum(st_br %in% c("ok", "here")),
                  sum(st_br == "failed"))
  } else {
    log[[length(log) + 1]] <- data.frame(year = y, uf = u, br = "", status = st)
  }
  message(y, " ", u, ": ", st)
}
log <- do.call(rbind, log)
write.csv(log, file.path(path_pnct_in, "download_log.csv"), row.names = FALSE)
print(table(log$year, log$status))
f <- list.files(path_pnct_in, pattern = "[.]zip$", full.names = TRUE)
message(length(f), " zips, ", round(sum(file.size(f)) / 1e6, 1), " MB")
