# =============================================================================
# 03_prf_clock_check.R
#
# Is the PRF clock time legal time (DST included) in every year?
#
# Test: for accidents in treated states, take the officer-recorded light phase
# (fase_dia) and the computed sunset. If "horario" is legal time, the share
# recorded as dark should jump at clock = legal sunset, i.e. at
#   sunset_std + 60 min on DST days, and sunset_std on other days.
# If some years were recorded in standard time, the jump on DST days would sit
# at sunset_std instead. The script locates the jump by season and regime:
# for each, the share dark by 10-minute bin of (clock - sunset_std), and the
# bin where the share first crosses 50%.
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

TREATED <- c("RS", "SC", "PR", "SP", "RJ", "ES", "MG", "GO", "MT", "MS", "DF")

sun_times <- function(date, lat, lon, offset_h) {
  doy <- as.integer(format(as.Date(date), "%j"))
  g   <- 2 * pi / 365 * (doy - 1 + 0.5)
  eqt <- 229.18 * (0.000075 + 0.001868 * cos(g) - 0.032077 * sin(g) -
                     0.014615 * cos(2 * g) - 0.040849 * sin(2 * g))
  dec <- 0.006918 - 0.399912 * cos(g) + 0.070257 * sin(g) - 0.006758 * cos(2 * g) +
    0.000907 * sin(2 * g) - 0.002697 * cos(3 * g) + 0.00148 * sin(3 * g)
  phi <- lat * pi / 180
  ha  <- acos(cos(90.833 * pi / 180) / (cos(phi) * cos(dec)) - tan(phi) * tan(dec)) * 180 / pi
  720 - 4 * (lon - ha) - eqt + 60 * offset_h          # sunset only
}

geo <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "geo", "output", "muni_geo.parquet")))
prf <- as.data.table(read_parquet(file.path(DROPBOX_ROOT, "build", "prf", "output", "prf_accidents.parquet")))
dst <- as.data.table(read_parquet(file.path(path_calendar_out, "dst_uf_day.parquet")))

norm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
geo[, key := paste(uf, norm(name))]
prf[, key := paste(uf, norm(municipio))]
# Name aliases, as in 01_sunset_design.R.
alias <- fread(file.path(path_manual, "prf_municipio_alias.csv"), encoding = "UTF-8")
alias <- geo[, .(code6, lat, lon, std_offset_h)][
  alias[, .(key = paste(uf, norm(municipio_prf)), code6)], on = "code6"]
keys <- rbind(unique(geo[, .(key, lat, lon, std_offset_h)], by = "key"),
              alias[!key %in% geo$key, .(key, lat, lon, std_offset_h)])
prf <- keys[prf, on = "key", nomatch = 0]
prf <- prf[uf %in% TREATED & fase_dia %in% c("pleno dia", "anoitecer", "plena noite") & !is.na(minute)]
prf <- dst[, .(uf, date, dst)][prf, on = .(uf, date)]

prf[, rel := 60L * hour + minute - sun_times(date, lat, lon, std_offset_h)]
prf <- prf[rel %between% c(-150, 210)]
prf[, dark := as.integer(fase_dia != "pleno dia")]
prf[, rbin := 10 * floor(rel / 10)]
prf[, sy := year(date) - (month(date) < 7L)]

# Bin where the share dark first reaches 50%, by season and DST regime.
cross <- prf[, .(share = mean(dark), n = .N), by = .(sy, dst, rbin)][order(sy, dst, rbin)][
  n >= 30, .(crossing_min = rbin[which(share >= 0.5)[1]], n = sum(n)), by = .(sy, dst)]
out <- dcast(cross, sy ~ dst, value.var = "crossing_min")
setnames(out, c("0", "1"), c("no_dst_days", "dst_days"), skip_absent = TRUE)
out[, gap := dst_days - no_dst_days]

# Same-calendar comparison: the summer window (Nov 15 - Feb 14), DST seasons
# vs post-abolition seasons. Twilight length is the same; only the clock moved.
md <- prf[, month(date) * 100L + mday(date)]
prf[, win := md >= 1115L | md <= 214L]
curve <- prf[win == TRUE & sy %between% c(2008L, 2023L),
             .(share_dark = round(mean(dark), 3), n = .N),
             by = .(period = fifelse(sy <= 2018L, "pre (DST)", "post (no DST)"), rbin)]
curve_w <- dcast(curve, rbin ~ period, value.var = "share_dark")
cross_w <- curve[n >= 30][order(period, rbin), .(crossing_min = rbin[which(share_dark >= 0.5)[1]]), by = period]

saveRDS(list(by_season = out, window_curve = curve_w, window_cross = cross_w),
        file.path(path_audit, "prf_clock_check.rds"))
cat("\nSummer window, share recorded dark by 10-min bin of clock - standard sunset:\n")
print(curve_w[rbin %between% c(-60, 120)])
cat("\nCrossing (legal time implies pre - post ~ +60):\n")
print(cross_w)
cat("Clock minutes after standard sunset at which >= 50% of PRF accidents are recorded dark.\n")
cat("Legal-time recording implies dst_days - no_dst_days ~ +60.\n\n")
print(out)
