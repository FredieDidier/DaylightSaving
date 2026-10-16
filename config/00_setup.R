# =============================================================================
# 00_setup.R
#
# Installs the R packages that the build and the analysis use, from the
# sources they were installed from (versions in README.md). Run once, before
# config/00_master_build.R:
#   Rscript config/00_setup.R
# Packages already installed are left as they are.
# =============================================================================

cran <- c("data.table", "arrow", "fixest", "dqrng", "ggplot2", "patchwork", "ragg",
          "sf", "terra", "geobr", "geodata", "rnaturalearth", "RCurl", "curl",
          "jsonlite", "dplyr", "here", "readxl", "remotes")
# Not on CRAN, or installed from a development build.
universe <- c(fwildclusterboot  = "https://s3alfisc.r-universe.dev",
              rnaturalearthdata = "https://ropensci.r-universe.dev")
github <- c(HonestDiD = "asheshrambachan/HonestDiD@6813f02ed38f0b63bdca6915604b2eac90491303",
            censobr   = "ipeaGIT/censobr@429440f52f8a4e2b869f6ad4aaf877576c680c80",
            read.dbc  = "danicat/read.dbc@52e0b15e79b8917e7814b0f8c20c14ae25b9f87e")

absent <- function(p) p[!vapply(p, requireNamespace, logical(1), quietly = TRUE)]
cran_repo <- "https://cloud.r-project.org"

if (length(absent(cran))) install.packages(absent(cran), repos = cran_repo)
for (p in absent(names(universe)))
  install.packages(p, repos = c(universe[[p]], cran_repo))
for (p in absent(names(github)))
  remotes::install_github(github[[p]], upgrade = "never")

still <- absent(c(cran, names(universe), names(github)))
if (length(still)) stop("not installed: ", paste(still, collapse = ", "))
message("All packages installed.")
