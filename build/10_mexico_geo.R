# =============================================================================
# 10_mexico_geo.R
#
# Mexico: one row per municipality with the coordinates of its seat
# (cabecera municipal), for the sunset of the Mexican replication
# (analysis/code/26_mexico.R).
#
# Source: INEGI web service of the Marco Geoestadistico (wscatgeo v2, Censo
# 2020 attributes):
#   mgem/{ent}                  municipalities of a state, with cve_cab, the
#                               locality code of the seat
#   localidades/{ent}/{mun}/{U|R}  urban / rural localities with latitude and
#                               longitude
# The seat is the locality whose code is cve_cab. Mexico City's alcaldias have
# no cabecera ("----"); the most populous urban locality stands in.
# Every response is cached as JSON under mexico/input/inegi_geo/, so a rerun
# does not query the service again.
#
# Output: mexico/output/mx_muni_geo.parquet (cve_ent, cve_mun, name, lat, lon,
#         seat_source)
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(jsonlite)
})

path_mx_in  <- file.path(DROPBOX_ROOT, "build", "mexico", "input", "inegi_geo")
path_mx_out <- file.path(DROPBOX_ROOT, "build", "mexico", "output")
dir.create(path_mx_in, recursive = TRUE, showWarnings = FALSE)
dir.create(path_mx_out, recursive = TRUE, showWarnings = FALSE)

BASE <- "https://gaia.inegi.org.mx/wscatgeo/v2"
get_json <- function(path) {
  f <- file.path(path_mx_in, paste0(gsub("/", "_", path), ".json"))
  if (!file.exists(f)) {
    for (k in 1:4) {
      ok <- tryCatch({ download.file(paste0(BASE, "/", path), f, quiet = TRUE); TRUE },
                     error = function(e) FALSE, warning = function(w) FALSE)
      if (ok && file.size(f) > 0) break
      unlink(f); Sys.sleep(2 * k)
    }
    if (!file.exists(f)) stop("failed: ", path)
  }
  fromJSON(f)
}

muni <- rbindlist(lapply(sprintf("%02d", 1:32), function(e) as.data.table(get_json(paste0("mgem/", e))$datos)), fill = TRUE)
stopifnot(nrow(muni) > 2400, !anyDuplicated(muni$cvegeo))

locs <- function(e, m, amb) {
  x <- tryCatch(get_json(sprintf("localidades/%s/%s/%s", e, m, amb)), error = function(err) NULL)
  if (is.null(x) || is.null(x$datos) || length(x$datos) == 0) return(NULL)
  d <- as.data.table(x$datos)
  # Some responses carry no locality rows (an error object or an empty list).
  if (!all(c("cve_loc", "latitud", "longitud") %in% names(d))) return(NULL)
  if (!"pob_total" %in% names(d)) d[, pob_total := NA]
  d[, .(cve_loc, nomgeo, lat = as.numeric(latitud), lon = as.numeric(longitud),
        pob = as.numeric(pob_total))]
}

out <- rbindlist(lapply(seq_len(nrow(muni)), function(i) {
  e <- muni$cve_ent[i]; m <- muni$cve_mun[i]; cab <- muni$cve_cab[i]
  u <- locs(e, m, "U")
  pick <- function(d) if (is.null(d)) NULL else d[d$cve_loc == cab]
  if (cab != "----") {
    s <- pick(u)
    if (is.null(s) || nrow(s) == 0) s <- pick(locs(e, m, "R"))
    if (!is.null(s) && nrow(s) == 1)
      return(data.table(cve_ent = e, cve_mun = m, name = muni$nomgeo[i], lat = s$lat, lon = s$lon,
                        seat_source = "cabecera"))
  }
  if (!is.null(u) && nrow(u) > 0) {
    s <- u[which.max(fcoalesce(pob, 0))]
    return(data.table(cve_ent = e, cve_mun = m, name = muni$nomgeo[i], lat = s$lat, lon = s$lon,
                      seat_source = "largest urban locality"))
  }
  data.table(cve_ent = e, cve_mun = m, name = muni$nomgeo[i], lat = NA_real_, lon = NA_real_,
             seat_source = "missing")
}))

print(out[, .N, by = seat_source])
stopifnot(out[!is.na(lat), all(lat %between% c(14, 33) & lon %between% c(-118, -86))])
write_parquet(out, file.path(path_mx_out, "mx_muni_geo.parquet"))
cat(sprintf("Municipalities: %d; with coordinates: %d\n", nrow(out), out[!is.na(lat), .N]))
