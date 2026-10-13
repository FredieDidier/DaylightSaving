# =============================================================================
# 04_municipal_geo.R
#
# One row per municipality: coordinates of the municipal seat (IBGE, via geobr,
# 2010 seats; the five municipalities installed in 2013 get a point inside
# their 2020 boundary) and the standard UTC offset of its time zone (no DST).
#
# Time zone per municipality (IANA zone): the state's zone, except the 13
# south-western Amazonas municipalities on Acre time (Eirunepe zone; the
# administrative list behind Lei 12.876/2013; the law draws a line rather
# than listing municipalities) and Fernando de Noronha. Standard offsets:
# Noronha -2; Sao_Paulo,
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
# Bandeira (RS), all 2013. Their deaths and crashes need a seat too, so a
# point on the surface of the 2020 boundary stands in for it; the sunset error
# is well under a minute.
mun20 <- read_municipality(year = 2020, showProgress = FALSE)
new   <- mun20[!as.integer(mun20$code_muni) %in% geo$code7, ]
xy_n  <- st_coordinates(suppressWarnings(st_point_on_surface(new)))
geo <- rbind(geo, data.table(code7 = as.integer(new$code_muni), name = new$name_muni,
                             uf = new$abbrev_state, lon = xy_n[, 1], lat = xy_n[, 2],
                             code6 = as.integer(new$code_muni) %/% 10L))
cat("added after 2010:", paste(new$name_muni, collapse = ", "), "\n")

STATE_TZ <- c(AC = "America/Rio_Branco", AL = "America/Maceio", AP = "America/Belem",
              AM = "America/Manaus", BA = "America/Bahia", CE = "America/Fortaleza",
              DF = "America/Sao_Paulo", ES = "America/Sao_Paulo", GO = "America/Sao_Paulo",
              MA = "America/Fortaleza", MT = "America/Cuiaba", MS = "America/Campo_Grande",
              MG = "America/Sao_Paulo", PA = "America/Belem", PB = "America/Fortaleza",
              PR = "America/Sao_Paulo", PE = "America/Recife", PI = "America/Fortaleza",
              RJ = "America/Sao_Paulo", RN = "America/Fortaleza", RS = "America/Sao_Paulo",
              RO = "America/Porto_Velho", RR = "America/Boa_Vista", SC = "America/Sao_Paulo",
              SP = "America/Sao_Paulo", SE = "America/Maceio", TO = "America/Araguaina")
AM_UTC5 <- c(1300201L, 1300607L, 1300706L, 1301407L, 1301506L, 1301654L, 1301803L,
             1301951L, 1302306L, 1302405L, 1303502L, 1303908L, 1304062L)
geo[, tz := unname(STATE_TZ[uf])]
geo[code7 %in% AM_UTC5, tz := "America/Eirunepe"]
geo[code7 == 2605459L, tz := "America/Noronha"]          # Fernando de Noronha
stopifnot(!anyNA(geo$tz), geo[tz == "America/Eirunepe", .N] == length(AM_UTC5))
setcolorder(geo, c("code7", "tz"))

offsets <- c("America/Noronha" = -2, "America/Sao_Paulo" = -3, "America/Fortaleza" = -3,
             "America/Recife" = -3, "America/Maceio" = -3, "America/Bahia" = -3,
             "America/Belem" = -3, "America/Araguaina" = -3, "America/Santarem" = -3,
             "America/Campo_Grande" = -4, "America/Cuiaba" = -4, "America/Porto_Velho" = -4,
             "America/Boa_Vista" = -4, "America/Manaus" = -4,
             "America/Rio_Branco" = -5, "America/Eirunepe" = -5)
geo[, std_offset_h := unname(offsets[tz])]
stopifnot(!anyNA(geo$lat), !anyNA(geo$std_offset_h), !anyDuplicated(geo$code6))

write_parquet(geo, file.path(path_geo_out, "muni_geo.parquet"))
cat(nrow(geo), "municipalities\n")
