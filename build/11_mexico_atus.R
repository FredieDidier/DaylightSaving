# =============================================================================
# 11_mexico_atus.R
#
# Mexico: traffic accidents on non-federal roads, one row per accident, from
# INEGI's ATUS ("Estadistica de Accidentes de Transito Terrestre en Zonas
# Urbanas y Suburbanas"), open data release of 28/08/2026, 1997-2025
# (https://www.inegi.org.mx/contenidos/programas/accidentes/datosabiertos/
#  conjunto_de_datos_atus_anual_csv.zip, downloaded 12/10/2026).
#
# Kept: 2013-2025. Clock time ID_HORA / ID_MINUTO (99 = not specified -> NA),
# day ID_DIA (32 = not specified -> NA). Victims are counted at the scene:
# *MUERTO = "muere en el lugar del accidente" (dictionary), the same concept as
# Brazil's on-road SIM deaths and PRF deaths.
#
# Output: mexico/output/atus_accidents.parquet with cve_ent, cve_mun, date,
#   cmin (clock minutes after midnight), deaths, ped_deaths, injured,
#   ped_crash (pedestrian struck), victims (any death or injury)
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

zipf <- file.path(DROPBOX_ROOT, "build", "mexico", "input", "atus_raw",
                  "conjunto_de_datos_atus_anual_csv.zip")
path_mx_out <- file.path(DROPBOX_ROOT, "build", "mexico", "output")
dir.create(path_mx_out, recursive = TRUE, showWarnings = FALSE)

YEARS <- 2013:2025
DEAD <- c("CONDMUERTO", "PASAMUERTO", "PEATMUERTO", "CICLMUERTO", "OTROMUERTO", "NEMUERTO")
HURT <- c("CONDHERIDO", "PASAHERIDO", "PEATHERIDO", "CICLHERIDO", "OTROHERIDO", "NEHERIDO")

atus <- rbindlist(lapply(YEARS, function(y) {
  x <- fread(cmd = sprintf("unzip -p '%s' conjunto_de_datos/atus_anual_%d.csv", zipf, y),
             encoding = "UTF-8", colClasses = list(character = c("CVE_ENT", "CVE_MUN", "CVEGEO")),
             select = c("CVE_ENT", "CVE_MUN", "ANIO", "MES", "ID_DIA", "ID_HORA", "ID_MINUTO",
                        "TIPACCID", "CLASACC", DEAD, HURT))
  stopifnot(all(x$ANIO == y))
  x
}))
for (v in c(DEAD, HURT)) set(atus, j = v, value = fcoalesce(as.integer(atus[[v]]), 0L))

atus[, `:=`(
  cve_ent = sprintf("%02d", as.integer(CVE_ENT)), cve_mun = sprintf("%03d", as.integer(CVE_MUN)),
  date = as.IDate(sprintf("%d-%02d-%02d", ANIO, as.integer(MES), as.integer(ID_DIA)), optional = TRUE),
  cmin = fifelse(ID_HORA %between% c(0L, 23L) & ID_MINUTO %between% c(0L, 59L),
                 60L * ID_HORA + ID_MINUTO, NA_integer_),
  deaths = rowSums(.SD[, DEAD, with = FALSE]), ped_deaths = PEATMUERTO,
  injured = rowSums(.SD[, HURT, with = FALSE]),
  ped_crash = grepl("peat", TIPACCID, ignore.case = TRUE))]
atus[, victims := deaths > 0L | injured > 0L]

qc <- atus[, .(accidents = .N, no_date_pct = round(100 * mean(is.na(date)), 2),
               no_time_pct = round(100 * mean(is.na(cmin)), 2), deaths = sum(deaths),
               ped_deaths = sum(ped_deaths), victim_accidents = sum(victims)), keyby = ANIO]
print(qc)
print(atus[, .N, by = TIPACCID][order(-N)])

out <- atus[!is.na(date), .(cve_ent, cve_mun, date, cmin, deaths, ped_deaths, injured, ped_crash, victims)]
write_parquet(as.data.frame(out[, date := as.Date(date)]), file.path(path_mx_out, "atus_accidents.parquet"),
              chunk_size = 1e6)
cat(sprintf("Wrote %s accidents, %d-%d\n", format(nrow(out), big.mark = ","), min(YEARS), max(YEARS)))
