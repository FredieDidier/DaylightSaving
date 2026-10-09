# =============================================================================
# 04_municipal_geo.R
#
# One row per municipality: coordinates of the municipal seat (IBGE, via geobr,
# 2010 seats; the five municipalities installed in 2013 get a point inside
# their 2020 boundary) and the standard UTC offset of its time zone (no DST).
#
# Time zone per municipality is borrowed from WorldCupHealth's muni_tz
# (IANA zone per municipality). Standard offsets: Noronha -2; Sao_Paulo,
# Fortaleza, Recife, Maceio, Bahia, Belem, Araguaina, Santarem -3 (Santarem
# since 2008); Campo_Grande, Cuiaba, Porto_Velho, Boa_Vista, Manaus -4;
# Rio_Branco, Eirunepe -5 (-4 between 2008-06-24 and 2013-11-10, see
# build/manual/fusos_mudancas.csv; AC and AM are outside the analysis groups).
#
# Output: geo/output/muni_geo.parquet (code6 = 6-digit IBGE code used by
# DATASUS, code7, name, uf, lat, lon, tz, std_offset_h).
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(geobr)
  library(sf)
})

path_geo_out <- file.path(DROPBOX_ROOT, "build", "geo", "output")
dir.create(path_geo_out, recursive = TRUE, showWarnings = FALSE)

seats <- read_municipal_seat(year = 2010, showProgress = FALSE)
xy    <- st_coordinates(seats)
geo   <- data.table(code7 = as.integer(seats$code_muni), name = seats$name_muni,
                    uf = seats$abbrev_state, lon = xy[, 1], lat = xy[, 2])
geo[, code6 := code7 %/% 10L]

# Municipalities installed after 2010 have no 2010 seat: Pescaria Brava and
# Balneario Rincao (SC), Paraiso das Aguas (MS), Mojui dos Campos (PA), Pinto
# Bandeira (RS), all 2013. Without them their deaths and crashes were dropped
# (code audit, 09/10/2026). Point on the surface of the 2020 boundary stands in
# for the seat; the sunset error is well under a minute.
mun20 <- read_municipality(year = 2020, showProgress = FALSE)
new   <- mun20[!as.integer(mun20$code_muni) %in% geo$code7, ]
xy_n  <- st_coordinates(suppressWarnings(st_point_on_surface(new)))
geo <- rbind(geo, data.table(code7 = as.integer(new$code_muni), name = new$name_muni,
                             uf = new$abbrev_state, lon = xy_n[, 1], lat = xy_n[, 2],
                             code6 = as.integer(new$code_muni) %/% 10L))
cat("added after 2010:", paste(new$name_muni, collapse = ", "), "\n")

tz <-as.data.table(read_parquet(
  "/Users/fredie/Library/CloudStorage/Dropbox/WorldCupHealth/build/MATCHES/muni_tz.parquet"))
geo <- tz[, .(code7 = as.integer(code_muni), tz)][geo, on = "code7"]

offsets <- c("America/Noronha" = -2, "America/Sao_Paulo" = -3, "America/Fortaleza" = -3,
             "America/Recife" = -3, "America/Maceio" = -3, "America/Bahia" = -3,
             "America/Belem" = -3, "America/Araguaina" = -3, "America/Santarem" = -3,
             "America/Campo_Grande" = -4, "America/Cuiaba" = -4, "America/Porto_Velho" = -4,
             "America/Boa_Vista" = -4, "America/Manaus" = -4,
             "America/Rio_Branco" = -5, "America/Eirunepe" = -5)
geo[, std_offset_h := unname(offsets[tz])]
# Municipalities missing from muni_tz (created after it, or name mismatch):
# fall back on the state's dominant zone.
geo[is.na(std_offset_h), std_offset_h := fcase(uf %in% c("MS", "MT", "RO", "RR", "AM"), -4,
                                               uf == "AC", -5, default = -3)]
stopifnot(!anyNA(geo$lat), !anyNA(geo$std_offset_h), !anyDuplicated(geo$code6))

write_parquet(geo, file.path(path_geo_out, "muni_geo.parquet"))
cat(nrow(geo), "municipalities;", geo[is.na(tz), .N], "without muni_tz zone (state fallback)\n")
