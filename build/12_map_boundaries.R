# =============================================================================
# 12_map_boundaries.R
#
# Boundaries for the two maps of the paper (analysis/code/29_figures.R): the
# Brazilian states and the Mexican states and municipalities. Nothing here
# enters an estimate.
#
#   Brazil  IBGE state boundaries, 2020, through geobr (simplified version).
#   Mexico  GADM 4.1, levels 1 (states) and 2 (municipalities), through
#           geodata::gadm. The raw GADM files are cached in mexico/input/gadm/.
#           Municipal polygons are kept only for the three states whose border
#           municipalities keep DST on US dates (Coahuila, Nuevo Leon,
#           Tamaulipas), the only ones the map draws one by one.
#
# Output (under DROPBOX_ROOT/build/):
#   geo/output/br_states.gpkg          code_state, abbrev_state, geometry
#   mexico/output/mx_states.gpkg       cve_ent, name, geometry
#   mexico/output/mx_border_states_munis.gpkg   cve_ent, name, geometry
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(sf)
  library(geobr)
  library(geodata)
})

path_geo_out <- file.path(DROPBOX_ROOT, "build", "geo", "output")
path_mx_in   <- file.path(DROPBOX_ROOT, "build", "mexico", "input", "gadm")
path_mx_out  <- file.path(DROPBOX_ROOT, "build", "mexico", "output")
for (p in c(path_geo_out, path_mx_in, path_mx_out)) dir.create(p, recursive = TRUE, showWarnings = FALSE)

# ── Brazil ──────────────────────────────────────────────────────────────────
br <- read_state(year = 2020, simplified = TRUE, showProgress = FALSE)
br <- br[, c("code_state", "abbrev_state")]
stopifnot(nrow(br) == 27L, setequal(br$abbrev_state, UFS))
st_write(br, file.path(path_geo_out, "br_states.gpkg"), delete_dsn = TRUE, quiet = TRUE)

# ── Mexico ──────────────────────────────────────────────────────────────────
# GADM's state order is alphabetical, which matches INEGI's state codes
# (01 Aguascalientes ... 32 Zacatecas); the names are checked below so that a
# change in GADM's order stops the build instead of mislabelling a state.
INEGI_STATES <- c("Aguascalientes", "Baja California", "Baja California Sur", "Campeche",
                  "Coahuila", "Colima", "Chiapas", "Chihuahua", "Ciudad de Mexico", "Durango",
                  "Guanajuato", "Guerrero", "Hidalgo", "Jalisco", "Mexico", "Michoacan",
                  "Morelos", "Nayarit", "Nuevo Leon", "Oaxaca", "Puebla", "Queretaro",
                  "Quintana Roo", "San Luis Potosi", "Sinaloa", "Sonora", "Tabasco",
                  "Tamaulipas", "Tlaxcala", "Veracruz", "Yucatan", "Zacatecas")
norm <- function(x) toupper(gsub("[^A-Za-z]", "", iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))
# GADM spells some states differently from INEGI's short names.
GADM_ALIAS <- c(DISTRITOFEDERAL = "CIUDADDEMEXICO", COAHUILADEZARAGOZA = "COAHUILA",
                MICHOACANDEOCAMPO = "MICHOACAN", VERACRUZDEIGNACIODELALLAVE = "VERACRUZ",
                ESTADODEMEXICO = "MEXICO")
key <- function(x) { k <- norm(x); ifelse(k %in% names(GADM_ALIAS), GADM_ALIAS[k], k) }

mx1 <- st_as_sf(gadm("MEX", level = 1, path = path_mx_in, version = "4.1"))
mx1$cve_ent <- sprintf("%02d", match(key(mx1$NAME_1), norm(INEGI_STATES)))
stopifnot(!anyNA(mx1$cve_ent), !anyDuplicated(mx1$cve_ent), nrow(mx1) == 32L)
mx1 <- st_simplify(st_transform(mx1[, c("cve_ent", "NAME_1")], 6372), dTolerance = 1000)
names(mx1)[names(mx1) == "NAME_1"] <- "name"
st_write(mx1, file.path(path_mx_out, "mx_states.gpkg"), delete_dsn = TRUE, quiet = TRUE)

mx2 <- st_as_sf(gadm("MEX", level = 2, path = path_mx_in, version = "4.1"))
mx2$cve_ent <- sprintf("%02d", match(key(mx2$NAME_1), norm(INEGI_STATES)))
stopifnot(!anyNA(mx2$cve_ent))
mx2 <- mx2[mx2$cve_ent %in% c("05", "19", "28"), c("cve_ent", "NAME_2")]
mx2 <- st_simplify(st_transform(mx2, 6372), dTolerance = 500)
names(mx2)[names(mx2) == "NAME_2"] <- "name"
st_write(mx2, file.path(path_mx_out, "mx_border_states_munis.gpkg"), delete_dsn = TRUE, quiet = TRUE)

cat("Brazil:", nrow(br), "states | Mexico:", nrow(mx1), "states,", nrow(mx2),
    "municipalities in Coahuila, Nuevo Leon and Tamaulipas\n")
