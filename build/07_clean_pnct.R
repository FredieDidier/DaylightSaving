# =============================================================================
# 07_clean_pnct.R
#
# Stacks the PNCT hourly volume files (build/06_download_pnct.R) into one
# station x date x clock hour x direction panel.
#
# Each zip holds, per station, <br>_<uf>_km<km>_<year>.csv: a UTF-8 (BOM),
# ';'-separated file whose first two lines are station metadata (UF, BR, Km,
# Ano, Latitude, Longitude) and whose third line is the header
#   Data;Hora;Sentido;(A) ... ;(J) Motocicleta;(L) Indefinido
# Hora is the clock hour 0-23 (which clock is tested in
# analysis/code/16_traffic_volume.R, as 04_prf_clock_check.R did for PRF);
# Sentido is C (increasing km) or D (decreasing). The _vmdm and _vtd summaries
# are not used.
#
# Output: pnct/output/pnct_hourly.parquet under DROPBOX_ROOT, columns
#   station (uf_br_km), uf, br, km, lat, lon, date, hour, dir,
#   heavy (classes A-H: buses and trucks), light (I cars + J motorcycles),
#   undef (L), total, imputed (station-day flagged as modelled, see below).
# A station-hour-direction that appears in more than one zip is kept once.
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

path_in  <- file.path(DROPBOX_ROOT, "build", "pnct", "input")
path_out <- file.path(DROPBOX_ROOT, "build", "pnct", "output")
dir.create(path_out, recursive = TRUE, showWarnings = FALSE)
tmp <- file.path(tempdir(), "pnct")

read_station <- function(f) {
  meta <- fread(f, nrows = 1, skip = 0, sep = ";", encoding = "UTF-8", colClasses = "character")
  setnames(meta, sub("^﻿", "", names(meta)))
  x <- fread(f, skip = 2, sep = ";", encoding = "UTF-8", colClasses = "character")
  if (nrow(x) == 0) return(NULL)
  cls <- names(x)[-(1:3)]
  x[, (cls) := lapply(.SD, as.numeric), .SDcols = cls]
  heavy <- grep("^\\([A-H]\\)", cls, value = TRUE)
  light <- grep("^\\((I|J)\\)", cls, value = TRUE)
  undef <- grep("^\\(L\\)", cls, value = TRUE)
  stopifnot(length(heavy) == 8, length(light) == 2)
  km <- as.numeric(sub(",", ".", meta$Km))
  data.table(station = sprintf("%s_%s_%s", meta$UF, meta$BR, meta$Km),
             uf = meta$UF, br = meta$BR, km = km,
             lat = as.numeric(sub(",", ".", meta$Latitude)),
             lon = as.numeric(sub(",", ".", meta$Longitude)),
             date = as.IDate(x[[1]], format = "%d/%m/%Y"), hour = as.integer(x[[2]]),
             dir = x[[3]],
             heavy = rowSums(x[, ..heavy]), light = rowSums(x[, ..light]),
             undef = if (length(undef)) x[[undef]] else 0)
}

zips <- list.files(path_in, pattern = "^vh_.*[.]zip$", full.names = TRUE)
out <- rbindlist(lapply(zips, function(z) {
  d <- file.path(tmp, basename(z)); unlink(d, recursive = TRUE)
  utils::unzip(z, exdir = d)
  f <- list.files(d, pattern = "_\\d{4}[.]csv$", recursive = TRUE, full.names = TRUE)
  r <- rbindlist(lapply(f, read_station))
  unlink(d, recursive = TRUE)
  r
}))
n_raw <- nrow(out)
out <- unique(out, by = c("station", "date", "hour", "dir"))
out[, total := heavy + light + undef]
stopifnot(out[, mean(is.na(date))] < 0.001, out[, all(hour %between% c(0L, 23L), na.rm = TRUE)])
out <- out[!is.na(date) & !is.na(hour)]
setorder(out, station, date, hour, dir)

# ── Imputed days ────────────────────────────────────────────────────────────
# The continuous-count contract ended in June 2019 (DNIT note of Dec 2020,
# reported by SINDISAN 14/12/2020); DNIT filled the rest of 2019 with a model.
# In the files those days look real (24 hours, both directions), but their
# daily totals repeat exactly on the same weekday a few weeks apart, which
# measured traffic never does (0 repeats Jan-May 2019 at DF km 17; 10-15 per
# month from 18 Jun 2019). Flag a station-day as imputed when its daily total
# equals the total of the same weekday 1-4 weeks before or after.
dtot <- out[, .(tot = sum(total)), by = .(station, date)]
dtot[, imputed := FALSE]
for (k in c(-28L, -21L, -14L, -7L, 7L, 14L, 21L, 28L)) {
  nb <- dtot[, .(station, date = date - k, tot_k = tot)]
  dtot[nb, on = .(station, date), imputed := imputed | (tot == i.tot_k & tot > 0)]
}
out <- dtot[, .(station, date, imputed)][out, on = .(station, date)]
setorder(out, station, date, hour, dir)
print(dcast(dtot[, .(pct = round(100 * mean(imputed), 1)), by = .(y = year(date), m = month(date))],
            y ~ m, value.var = "pct"))
write_parquet(out, file.path(path_out, "pnct_hourly.parquet"))

cat(sprintf("zips %d | rows %d | after dedup %d | stations %d\n",
            length(zips), n_raw, nrow(out), uniqueN(out$station)))
print(out[, .(stations = uniqueN(station), station_days = uniqueN(paste(station, date)),
              veh_millions = round(sum(total) / 1e6, 1)), keyby = .(year = year(date))])
