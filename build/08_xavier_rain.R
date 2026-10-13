# =============================================================================
# 08_xavier_rain.R
#
# Daily precipitation at each municipal seat, July 2008 - June 2025, from the
# Xavier BR-DWGD v3.2.4 grid (0.1 degree; the cell that contains the seat).
# Used by analysis/code/22_light_dose.R: on a rainy, overcast evening the
# clock hour after standard sunset was already dim under DST, so abolition
# should darken it less.
#
# Input:  path_xavier_pr (config.R): weather/input/pr_20010101_20251231_
#         BR-DWGD_UFES_UTEXAS_v_3.2.4.nc, the raw NetCDF as distributed at
#         https://sites.google.com/site/alexandrecandidoxavierufes/brazilian-daily-weather-gridded-data
#         (manual download, no script; kept in Dropbox for that reason)
#         geo/output/muni_geo.parquet (04_municipal_geo.R)
# Output: weather/output/pr_seat_day.parquet (code6, date, pr_mm)
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(terra)
})

path_weather_out <- file.path(DROPBOX_ROOT, "build", "weather", "output")
dir.create(path_weather_out, recursive = TRUE, showWarnings = FALSE)

geo <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output", "muni_geo.parquet")))
r   <- rast(path_xavier_pr)
dates <- as.IDate(time(r))
keep  <- which(dates >= as.IDate("2008-07-01") & dates <= as.IDate("2025-06-30"))
stopifnot(length(keep) == as.integer(as.IDate("2025-06-30") - as.IDate("2008-07-01")) + 1L)

cells <- cellFromXY(r, geo[, cbind(lon, lat)])
# Seats outside the grid (Fernando de Noronha, 350 km offshore) get no rain.
off_grid <- geo[is.na(cells), .(code6, name, uf)]
print(off_grid)
stopifnot(nrow(off_grid) <= 1L)
geo <- geo[!is.na(cells)]; cells <- cells[!is.na(cells)]

# Read in yearly blocks of layers to bound memory.
blocks <- split(keep, ceiling(seq_along(keep) / 366))
out <- rbindlist(lapply(blocks, function(k) {
  v <- r[[k]][cells]                       # cells x layers
  data.table(code6 = rep(geo$code6, times = length(k)),
             date  = rep(dates[k], each = nrow(geo)),
             pr_mm = as.numeric(as.matrix(v)))
}))
# Coastal seats can fall in a sea cell of the grid (NA); take the nearest
# land cell within 0.3 degrees instead.
miss <- out[, .(na = all(is.na(pr_mm))), by = code6][na == TRUE, code6]
if (length(miss)) {
  cat("Seats in a cell without data:", length(miss), "- using the nearest cell with data\n")
  land <- which(!is.na(values(r[[keep[1]]], mat = FALSE)))
  xy_land <- xyFromCell(r, land)
  for (c6 in miss) {
    g <- geo[code6 == c6]
    d <- (xy_land[, 1] - g$lon)^2 + (xy_land[, 2] - g$lat)^2
    stopifnot(min(d) <= 0.3^2)
    cell <- land[which.min(d)]
    out[code6 == c6, pr_mm := as.numeric(as.matrix(r[[keep]][cell]))[match(date, dates[keep])]]
  }
}
stopifnot(!anyNA(out$pr_mm))
# Plain Date and no data.table attributes: a single 35-million-row group with
# R metadata exceeded arrow's thrift limit on reading.
out[, date := as.Date(date)]
write_parquet(as.data.frame(out), file.path(path_weather_out, "pr_seat_day.parquet"),
              chunk_size = 2e6)
cat(sprintf("Wrote %s seat-days, %d seats, %s to %s\n", format(nrow(out), big.mark = ","),
            uniqueN(out$code6), min(out$date), max(out$date)))
