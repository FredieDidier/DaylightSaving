# =============================================================================
# 12_coastal_municipalities.R
#
# The municipalities that face the sea ("municipios defrontantes com o mar"),
# IBGE's official list of 2022: 279 municipalities in 17 states, plus the Lagoa
# dos Patos (code 4300002), a lagoon IBGE codes like a municipality and which is
# dropped. The analysis
# drops them to check that the summer exodus to the beaches does not drive the
# estimate (20_leave_out.R).
#
# Source: https://geoftp.ibge.gov.br/organizacao_do_territorio/
# estrutura_territorial/municipios_defrontantes_com_o_mar/2022/
# Municipios_Defrontantes_com_o_Mar_2022.xls (downloaded 2026-10-16).
#
# Output: geo/output/muni_coastal.parquet under DROPBOX_ROOT (code7, code6,
#   name, uf), and the raw xls in geo/input/.
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
})

url  <- paste0("https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/",
               "municipios_defrontantes_com_o_mar/2022/Municipios_Defrontantes_com_o_Mar_2022.xls")
path_in  <- file.path(DROPBOX_ROOT, "build", "geo", "input")
path_out <- file.path(DROPBOX_ROOT, "build", "geo", "output")
dir.create(path_in, recursive = TRUE, showWarnings = FALSE)
xls <- file.path(path_in, basename(url))
if (!file.exists(xls)) utils::download.file(url, xls, mode = "wb", quiet = TRUE)

x <- as.data.table(readxl::read_excel(xls))
coast <- x[, .(code7 = as.integer(CD_MUN), name = NM_MUN, uf = SIGLA_UF)]
coast[, code6 := code7 %/% 10L]
stopifnot(nrow(coast) == 280L, !anyNA(coast$code7), !anyDuplicated(coast$code7))

# Every listed municipality must be one of the municipal seats of 04; the only
# other code on the list is the Lagoa dos Patos.
geo <- as.data.table(read_parquet(file.path(path_out, "muni_geo.parquet"), col_select = c("code7", "uf")))
stopifnot(identical(coast[!code7 %in% geo$code7, code7], 4300002L))
coast <- coast[code7 %in% geo$code7]
stopifnot(nrow(coast) == 279L, all(geo[match(coast$code7, code7), uf] == coast$uf))

write_parquet(coast[, .(code7, code6, name, uf)], file.path(path_out, "muni_coastal.parquet"))
print(coast[, .N, by = uf][order(uf)])
