# =============================================================================
# 09_census_lighting.R
#
# Street lighting by municipality, two censuses.
#
# 2022 (main; the most recent and the closest to abolition in 2019). IBGE,
#   Censo Demografico 2022, Pesquisa Urbanistica do Entorno dos Domicilios,
#   SIDRA table 9839, variable 9599 (occupied permanent private households in
#   tracts selected for the survey), classification 14: public lighting
#   exists (72254) / does not exist (72255) / not declared (72256); all
#   destinations of garbage (67 = 10972, total). Queried 12/10/2026:
#   https://apisidra.ibge.gov.br/values/t/9839/n6/all/v/9599/p/2022/c67/10972/c14/72254,72255,72256
#   (saved as census/input/sidra_9839_iluminacao_2022.json).
#   unlit_pct_2022 = 100 * not exists / (exists + not exists); "not declared"
#   is left out of the denominator.
#
# 2010 (robustness). Census 2010 tract file "Entorno" (censobr 0.2.0). For each
#   street face with permanent private households, whether there was at least
#   one public-light pole on that face or the opposite one (dictionary,
#   2.7.9). Urban tracts only (situation 1-3). Entorno01:
#     V008 / V009 owned, V010 / V011 rented, V012 / V013 ceded: exists / not.
#   unlit_pct_2010 = 100 * (V009 + V011 + V013) / (V008 + ... + V013).
#   The eight columns used are kept as census/input/
#   censo2010_entorno_lighting.parquet; when it is missing they are fetched
#   with censobr::read_tracts(2010, "Entorno") and saved there.
#
# Output: census/output/muni_lighting.parquet (code6, code7, unlit_pct_2022,
#         households_2022, unlit_pct_2010, households_urban_2010)
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(jsonlite)
})

path_census_in  <- file.path(DROPBOX_ROOT, "build", "census", "input")
path_census_out <- file.path(DROPBOX_ROOT, "build", "census", "output")
dir.create(path_census_in, recursive = TRUE, showWarnings = FALSE)
dir.create(path_census_out, recursive = TRUE, showWarnings = FALSE)

# ── 2022 ────────────────────────────────────────────────────────────────────
f22 <- file.path(path_census_in, "sidra_9839_iluminacao_2022.json")
if (!file.exists(f22))
  download.file(paste0("https://apisidra.ibge.gov.br/values/t/9839/n6/all/v/9599/p/2022/",
                       "c67/10972/c14/72254,72255,72256"), f22, quiet = TRUE)
s <- as.data.table(fromJSON(f22))[-1]                  # first row is the header
stopifnot(all(s$D2C == "9599"), all(s$D3C == "2022"), all(s$D4C == "10972"))
s[, n := suppressWarnings(as.numeric(V))]              # "-" = zero, "..." = missing
s[V == "-", n := 0]
w22 <- dcast(s, D1C ~ D5C, value.var = "n")
setnames(w22, c("D1C", "72254", "72255", "72256"), c("code7", "lit", "unlit", "undeclared"))
w22[, `:=`(code7 = as.integer(code7), households_2022 = lit + unlit)]
w22[, unlit_pct_2022 := fifelse(households_2022 > 0, 100 * unlit / households_2022, NA_real_)]
stopifnot(!anyDuplicated(w22$code7), w22[!is.na(unlit_pct_2022), all(unlit_pct_2022 %between% c(0, 100))])

# ── 2010 ────────────────────────────────────────────────────────────────────
cols <- c("code_muni", "entorno01_V1005", sprintf("entorno01_V%03d", 8:13))
f10 <- file.path(path_census_in, "censo2010_entorno_lighting.parquet")
if (!file.exists(f10))
  write_parquet(dplyr::collect(dplyr::select(
    censobr::read_tracts(year = 2010, dataset = "Entorno", showProgress = FALSE),
    dplyr::all_of(cols))), f10, compression = "zstd")
e <- as.data.table(read_parquet(f10, col_select = dplyr::all_of(cols)))
setnames(e, sub("entorno01_", "", names(e)))
e <- e[V1005 %in% 1:3]
for (x in sprintf("V%03d", 8:13)) set(e, j = x, value = fcoalesce(as.numeric(e[[x]]), 0))
w10 <- e[, .(lit = sum(V008 + V010 + V012), unlit = sum(V009 + V011 + V013)), by = code_muni]
w10[, `:=`(code7 = as.integer(code_muni), households_urban_2010 = lit + unlit)]
w10[, unlit_pct_2010 := fifelse(households_urban_2010 > 0, 100 * unlit / households_urban_2010, NA_real_)]
stopifnot(!anyDuplicated(w10$code7))

m <- merge(w22[, .(code7, unlit_pct_2022, households_2022)],
           w10[, .(code7, unlit_pct_2010, households_urban_2010)], by = "code7", all = TRUE)
m[, code6 := code7 %/% 10L]
write_parquet(m, file.path(path_census_out, "muni_lighting.parquet"))
cat(sprintf("Municipalities: %d. Median unlit share 2022 %.1f%%, 2010 %.1f%%; correlation %.2f\n",
            nrow(m), median(m$unlit_pct_2022, na.rm = TRUE), median(m$unlit_pct_2010, na.rm = TRUE),
            m[, cor(unlit_pct_2022, unlit_pct_2010, use = "complete.obs")]))
