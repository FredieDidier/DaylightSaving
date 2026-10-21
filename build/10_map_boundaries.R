# =============================================================================
# 10_map_boundaries.R
#
# State boundaries for the map of the paper (analysis/code/27_figures.R).
# Nothing here enters an estimate.
#
#   IBGE state boundaries, 2020, through geobr (simplified version).
#
# Output (under DROPBOX_ROOT/build/):
#   geo/output/br_states.gpkg          code_state, abbrev_state, geometry
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(sf)
  library(geobr)
})

path_geo_out <- file.path(DROPBOX_ROOT, "build", "geo", "output")
dir.create(path_geo_out, recursive = TRUE, showWarnings = FALSE)

br <- read_state(year = 2020, simplified = TRUE, showProgress = FALSE)
br <- br[, c("code_state", "abbrev_state")]
stopifnot(nrow(br) == 27L, setequal(br$abbrev_state, UFS))
st_write(br, file.path(path_geo_out, "br_states.gpkg"), delete_dsn = TRUE, quiet = TRUE)

cat("Brazil:", nrow(br), "states\n")
