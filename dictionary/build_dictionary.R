# =============================================================================
# build_dictionary.R
#
# Writes the data dictionary of every dataset the build produces, in
# Portuguese and English, as dictionary/data_dictionary.xlsx.
#
# The descriptions are typed below. Everything else is read from the data
# each time the script runs: rows, columns, size, type of each variable, share
# missing, distinct values, range, most frequent values, and the frequency of
# each code. The script stops if a dataset has a column the dictionary does
# not describe, or the dictionary describes a column the dataset lacks.
#
# Sheets
#   Leia-me · Read me      what the file is and how to read it
#   Bases · Datasets       one row per file, linked to its sheet
#   Variáveis · Variables  every variable in one filterable list
#   UFs                    the 27 states: IBGE code, analysis group, time zone
#   one sheet per dataset  file card, variables, codes with frequencies
#   manual                 the hand-coded tables in build/manual/ (in git)
#
# Usage   Rscript dictionary/build_dictionary.R
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))   # TREATED, CONTROL, UF_CODE
suppressPackageStartupMessages({
  library(duckdb)
  library(openxlsx)
})
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

B <- file.path(DROPBOX_ROOT, "build")
out_path <- here::here("dictionary", "data_dictionary.xlsx")

# ── Helpers to type the dictionary ──────────────────────────────────────────
# origin: "fonte" = published by the source (renamed or reformatted at most);
#         "projeto" = built by the project's scripts;
#         "manual" = typed by hand from legal acts or source pages.
v <- function(variable, origin, pt, en, pt_note = "", en_note = "")
  data.table(variable, origin, pt, pt_note, en, en_note)
# One code of a variable; `cond` is the SQL condition that counts it.
cv <- function(variable, value, pt, en, cond = NULL) {
  if (is.null(cond))
    cond <- if (value == "NA") sprintf('"%s" IS NULL', variable)
            else sprintf("CAST(\"%s\" AS VARCHAR) = '%s'", variable, value)
  data.table(variable, value, pt, en, cond)
}
# Codes of a free-text variable whose spelling varies across years: raw labels
# are grouped by their English translation, looked up by the label in lower
# case without accents.
norm <- function(x) {
  y <- tolower(iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT"))
  y <- trimws(gsub(" +", " ", gsub("[^a-z /()]", "", y)))
  y[!is.na(x) & y == ""] <- "<EMPTY>"
  y[is.na(x)] <- "<NA>"
  y
}

FAMILY <- c(calendar = "#7030A0", geo = "#548235", sim = "#C00000", prf = "#C55A11",
            pnct = "#2E75B6", weather = "#0E8A9E", census = "#BF8F00", manual = "#595959")

D <- list()

# ── Calendar ────────────────────────────────────────────────────────────────
D$dst_uf_season <- list(
  family = "calendar", file = "calendar/output/dst_uf_season.parquet",
  builder = "build/01_dst_calendar.R",
  title_pt = "Calendário legal do horário de verão, UF × temporada",
  title_en = "Legal DST calendar, state × season",
  unit_pt = "UF × temporada de horário de verão (27 UFs × 34 temporadas).",
  unit_en = "State × DST season (27 states × 34 seasons).",
  key = "temporada, uf",
  coverage_pt = "Temporadas 1985/86 a 2018/19, a última antes do Decreto 9.772/2019.",
  coverage_en = "Seasons 1985/86 to 2018/19, the last before Decree 9,772/2019.",
  source_pt = "Decretos lidos no Planalto (textos em horario_verao/fontes_legais/), digitados em build/manual/hv_temporadas.csv e hv_excecoes.csv.",
  source_en = "Decrees read at planalto.gov.br (texts in horario_verao/fontes_legais/), typed into build/manual/hv_temporadas.csv and hv_excecoes.csv.",
  vars = rbind(
    v("temporada", "manual", "Temporada de horário de verão, nomeada pelos dois anos que atravessa.",
      "DST season, named by the two calendar years it spans.",
      "Formato aaaa/aa, ex. 2018/19.", "Format yyyy/yy, e.g. 2018/19."),
    v("uf", "manual", "Sigla da unidade da federação.", "State (federative unit) abbreviation.",
      "27 siglas; ver a aba UFs.", "27 abbreviations; see the UFs sheet."),
    v("status", "projeto", "Se a UF teve horário de verão na temporada.",
      "Whether the state had DST in the season.",
      "in = a temporada inteira; partial = parte dela (saídas no meio de 2000/01); out = nenhum dia.",
      "in = the whole season; partial = part of it (mid-season exits in 2000/01); out = no day."),
    v("dst_days", "projeto", "Dias com o relógio adiantado na UF: fim_uf − inicio_uf.",
      "Days with clocks advanced in the state: fim_uf − inicio_uf.",
      "0 quando status = out.", "0 when status = out."),
    v("inicio_uf", "manual", "Primeiro dia com horário de verão na UF (a troca é à 00:00 local).",
      "First day of DST in the state (clocks change at 00:00 local time).",
      "Ausente quando status = out.", "Missing when status = out."),
    v("fim_uf", "manual", "Dia em que o relógio volta na UF; esse dia já é horário padrão.",
      "Day clocks go back in the state; that day is already standard time.",
      "Ausente quando status = out. Um dia tem horário de verão quando inicio_uf ≤ data < fim_uf.",
      "Missing when status = out. A day has DST when inicio_uf ≤ date < fim_uf."),
    v("season_start", "manual", "Início nacional da temporada, pelo decreto principal.",
      "National start of the season, per the main decree."),
    v("season_end", "manual", "Fim nacional da temporada, pelo decreto principal.",
      "National end of the season, per the main decree."),
    v("atos", "manual", "Atos legais que regem a temporada.", "Legal acts governing the season.",
      "Ex. \"Dec 6.558/2008\"; vários separados por ponto e vírgula.",
      "E.g. \"Dec 6.558/2008\"; several separated by semicolons."),
    v("verificacao", "manual", "Como as datas foram conferidas.", "How the dates were verified.",
      "Ver os códigos abaixo.", "See the codes below.")),
  codes = rbind(
    cv("status", "in", "Horário de verão a temporada inteira", "DST the whole season"),
    cv("status", "partial", "Parte da temporada", "Part of the season"),
    cv("status", "out", "Sem horário de verão", "No DST"),
    cv("verificacao", "planalto", "Texto do decreto lido no Planalto", "Decree text read at planalto.gov.br"),
    cv("verificacao", "regra", "Sem decreto próprio; datas da regra permanente do Dec. 6.558/2008, conferidas pelo script",
       "No decree of its own; dates from the permanent rule of Decree 6,558/2008, checked by the script"),
    cv("verificacao", "parcial", "Texto do Dec. 91.698/1985 não localizado; datas confirmadas pelos decretos de 1986",
       "Text of Decree 91,698/1985 not found; dates confirmed by the 1986 decrees")))

D$dst_uf_day <- list(
  family = "calendar", file = "calendar/output/dst_uf_day.parquet",
  builder = "build/01_dst_calendar.R",
  title_pt = "Calendário legal do horário de verão, UF × dia",
  title_en = "Legal DST calendar, state × day",
  unit_pt = "UF × dia do calendário.", unit_en = "State × calendar day.",
  key = "uf, date",
  coverage_pt = "1º/jan/1985 a 31/dez/2026, 27 UFs.", coverage_en = "1 Jan 1985 to 31 Dec 2026, 27 states.",
  source_pt = "Derivado de dst_uf_season.", source_en = "Derived from dst_uf_season.",
  vars = rbind(
    v("uf", "manual", "Sigla da unidade da federação.", "State abbreviation."),
    v("date", "projeto", "Data do calendário.", "Calendar date."),
    v("dst", "projeto", "1 se o relógio esteve adiantado o dia inteiro na UF.",
      "1 if clocks were advanced in the state for the whole day.",
      "1 quando inicio_uf ≤ date < fim_uf; 0 caso contrário.", "1 when inicio_uf ≤ date < fim_uf; 0 otherwise."),
    v("temporada", "projeto", "Temporada (julho a junho) a que o dia pertence, tendo ou não horário de verão.",
      "Season (July to June) the day belongs to, whether or not DST applied.",
      "Jan–jun/1985 caem em 1984/85; dias de 2019/20 em diante existem mas têm dst = 0.",
      "Jan–Jun 1985 fall in 1984/85; days from 2019/20 on exist but have dst = 0.")),
  codes = rbind(cv("dst", "1", "Horário de verão", "DST"), cv("dst", "0", "Horário padrão", "Standard time")))

# ── Geography ───────────────────────────────────────────────────────────────
D$muni_geo <- list(
  family = "geo", file = "geo/output/muni_geo.parquet", builder = "build/04_municipal_geo.R",
  title_pt = "Municípios: sede e fuso horário", title_en = "Municipalities: seat and time zone",
  unit_pt = "Município (5.570).", unit_en = "Municipality (5,570).", key = "code7 (ou code6)",
  coverage_pt = "Malha de 2010, mais os 5 municípios instalados em 2013.",
  coverage_en = "2010 municipal map, plus the 5 municipalities installed in 2013.",
  source_pt = "IBGE via geobr: sedes municipais de 2010; para os criados em 2013, um ponto dentro do limite de 2020. Fuso: zona IANA da UF, com exceções.",
  source_en = "IBGE via geobr: 2010 municipal seats; for those created in 2013, a point inside the 2020 boundary. Time zone: the state's IANA zone, with exceptions.",
  vars = rbind(
    v("code7", "fonte", "Código IBGE do município, 7 dígitos.", "IBGE municipality code, 7 digits."),
    v("tz", "projeto", "Fuso horário IANA do município.", "IANA time zone of the municipality.",
      "O da UF, exceto 13 municípios do sudoeste do AM (America/Eirunepe) e Fernando de Noronha (America/Noronha).",
      "The state's, except 13 south-western Amazonas municipalities (America/Eirunepe) and Fernando de Noronha (America/Noronha)."),
    v("name", "fonte", "Nome do município.", "Municipality name."),
    v("uf", "fonte", "Sigla da UF.", "State abbreviation."),
    v("lon", "fonte", "Longitude da sede municipal, graus decimais.", "Longitude of the municipal seat, decimal degrees.",
      "Leste positivo (todos negativos no Brasil).", "East positive (all negative in Brazil)."),
    v("lat", "fonte", "Latitude da sede municipal, graus decimais.", "Latitude of the municipal seat, decimal degrees."),
    v("code6", "projeto", "Código IBGE de 6 dígitos (code7 sem o dígito verificador), o usado pelo DATASUS.",
      "6-digit IBGE code (code7 without the check digit), as used by DATASUS."),
    v("std_offset_h", "projeto", "Diferença da hora padrão local (sem horário de verão) para o UTC, em horas.",
      "Offset of local standard time (without DST) from UTC, in hours.",
      "Valor atual. AC e sudoeste do AM: −5, mas −4 entre 24/06/2008 e 10/11/2013 (build/manual/fusos_mudancas.csv). Usado para calcular o pôr e o nascer do sol em hora padrão.",
      "Current value. AC and south-western AM: −5, but −4 between 24 Jun 2008 and 10 Nov 2013 (build/manual/fusos_mudancas.csv). Used to compute sunset and sunrise in standard time.")),
  codes = rbind(
    cv("std_offset_h", "-2", "UTC−2: Fernando de Noronha", "UTC−2: Fernando de Noronha", "std_offset_h = -2"),
    cv("std_offset_h", "-3", "UTC−3: hora de Brasília", "UTC−3: Brasília time", "std_offset_h = -3"),
    cv("std_offset_h", "-4", "UTC−4: MS, MT, RO, RR, AM", "UTC−4: MS, MT, RO, RR, AM", "std_offset_h = -4"),
    cv("std_offset_h", "-5", "UTC−5: AC e sudoeste do AM", "UTC−5: AC and south-western AM", "std_offset_h = -5")))

D$muni_coastal <- list(
  family = "geo", file = "geo/output/muni_coastal.parquet", builder = "build/12_coastal_municipalities.R",
  title_pt = "Municípios defrontantes com o mar", title_en = "Municipalities facing the sea",
  unit_pt = "Município defrontante com o mar (279).", unit_en = "Municipality facing the sea (279).",
  key = "code7", coverage_pt = "Lista oficial do IBGE de 2022, 17 UFs.", coverage_en = "IBGE official list of 2022, 17 states.",
  source_pt = "IBGE, Municípios Defrontantes com o Mar 2022 (a Lagoa dos Patos, codificada como município, é retirada).",
  source_en = "IBGE, Municipalities Facing the Sea 2022 (Lagoa dos Patos, coded like a municipality, is dropped).",
  vars = rbind(
    v("code7", "fonte", "Código IBGE do município, 7 dígitos.", "IBGE municipality code, 7 digits."),
    v("code6", "projeto", "Código IBGE de 6 dígitos (DATASUS).", "6-digit IBGE code (DATASUS)."),
    v("name", "fonte", "Nome do município.", "Municipality name."),
    v("uf", "fonte", "Sigla da UF.", "State abbreviation.")),
  codes = NULL)

D$br_states <- list(
  family = "geo", file = "geo/output/br_states.gpkg", builder = "build/10_map_boundaries.R",
  title_pt = "Limites das UFs (só para o mapa)", title_en = "State boundaries (map only)",
  unit_pt = "UF (27).", unit_en = "State (27).", key = "code_state",
  coverage_pt = "Malha estadual de 2020, versão simplificada.", coverage_en = "2020 state boundaries, simplified version.",
  source_pt = "IBGE via geobr::read_state(2020). Não entra em nenhuma estimativa.",
  source_en = "IBGE via geobr::read_state(2020). Enters no estimate.",
  vars = rbind(
    v("code_state", "fonte", "Código IBGE da UF, 2 dígitos.", "IBGE state code, 2 digits."),
    v("abbrev_state", "fonte", "Sigla da UF.", "State abbreviation."),
    v("geom", "fonte", "Polígono do limite da UF.", "State boundary polygon.",
      "Geometria; SIRGAS 2000 (EPSG 4674).", "Geometry; SIRGAS 2000 (EPSG 4674).")),
  codes = NULL)

# ── Census ──────────────────────────────────────────────────────────────────
D$muni_lighting <- list(
  family = "census", file = "census/output/muni_lighting.parquet", builder = "build/09_census_lighting.R",
  title_pt = "Iluminação pública por município", title_en = "Street lighting by municipality",
  unit_pt = "Município.", unit_en = "Municipality.", key = "code7",
  coverage_pt = "Censos de 2022 (principal) e 2010 (robustez).", coverage_en = "2022 (main) and 2010 (robustness) censuses.",
  source_pt = "2022: IBGE, Censo 2022, Pesquisa Urbanística do Entorno dos Domicílios, SIDRA tabela 9839. 2010: arquivo Entorno do Censo 2010 por setor (censobr), setores urbanos.",
  source_en = "2022: IBGE, 2022 Census, Urban Survey of Household Surroundings, SIDRA table 9839. 2010: 2010 Census tract file \"Entorno\" (censobr), urban tracts.",
  vars = rbind(
    v("code7", "fonte", "Código IBGE do município, 7 dígitos.", "IBGE municipality code, 7 digits."),
    v("unlit_pct_2022", "projeto", "% de domicílios sem iluminação pública no entorno, 2022.",
      "% of households without street lighting around them, 2022.",
      "100 × não existe / (existe + não existe); \"não declarado\" fica fora do denominador.",
      "100 × does not exist / (exists + does not exist); \"not declared\" is left out of the denominator."),
    v("households_2022", "projeto", "Domicílios particulares permanentes ocupados com a iluminação declarada, 2022 (denominador de unlit_pct_2022).",
      "Occupied permanent private households with lighting declared, 2022 (denominator of unlit_pct_2022).",
      "Só os setores da Pesquisa Urbanística.", "Only the tracts in the Urban Survey."),
    v("unlit_pct_2010", "projeto", "% de domicílios urbanos em face de quadra sem poste de iluminação pública, 2010.",
      "% of urban households on a street face without a public light pole, 2010.",
      "Face própria ou oposta; domicílios próprios, alugados e cedidos (V008–V013).",
      "Own or opposite face; owned, rented and ceded households (V008–V013)."),
    v("households_urban_2010", "projeto", "Domicílios particulares permanentes em setores urbanos, 2010 (denominador de unlit_pct_2010).",
      "Permanent private households in urban tracts, 2010 (denominator of unlit_pct_2010)."),
    v("code6", "projeto", "Código IBGE de 6 dígitos (DATASUS).", "6-digit IBGE code (DATASUS).")),
  codes = NULL)

# ── SIM ─────────────────────────────────────────────────────────────────────
D$sim <- list(
  family = "sim", file = "sim/output/sim_<ano>.parquet", glob = "sim/output/sim_*.parquet",
  builder = "build/05_download_sim.R",
  title_pt = "Declarações de óbito (SIM)", title_en = "Death certificates (SIM)",
  unit_pt = "Óbito (uma declaração de óbito). Um arquivo por ano.",
  unit_en = "Death (one death certificate). One file per year.",
  key = "— (sem identificador)",
  coverage_pt = "Óbitos de 2008 a 2025 no Brasil; 2025 é preliminar e fica fora da análise.",
  coverage_en = "Deaths in Brazil, 2008 to 2025; 2025 is preliminary and left out of the analysis.",
  source_pt = "Ministério da Saúde, Sistema de Informações sobre Mortalidade, FTP do DATASUS (arquivos DO<UF><ano>.dbc; nacional DOBR em 2010–2012). Só 9 das variáveis originais são mantidas.",
  source_en = "Ministry of Health, Mortality Information System, DATASUS FTP (files DO<UF><year>.dbc; national DOBR in 2010–2012). Only 9 of the original variables are kept.",
  vars = rbind(
    v("DTOBITO", "fonte", "Data do óbito.", "Date of death.", "Texto ddmmaaaa.", "Text ddmmyyyy."),
    v("HORAOBITO", "fonte", "Hora do óbito, em hora legal local.", "Time of death, in local legal (clock) time.",
      "Texto hhmm. Válida quando tem 4 caracteres, hh 00–23 e mm 00–59. É a hora do óbito, não do acidente: para quem morre no hospital pode ser horas ou dias depois, por isso só os óbitos em via pública (LOCOCOR = 4) entram nas contagens por hora.",
      "Text hhmm. Valid when 4 characters long, hh 00–23 and mm 00–59. It is the time of death, not of the crash: for hospital deaths it may be hours or days later, so only deaths on the public road (LOCOCOR = 4) enter the hourly counts."),
    v("CODMUNOCOR", "fonte", "Município de ocorrência do óbito, código IBGE de 6 dígitos.",
      "Municipality where the death occurred, 6-digit IBGE code.",
      "Liga com code6 de muni_geo. Terminado em 0000: município ignorado dentro da UF.",
      "Links to code6 in muni_geo. Ending in 0000: municipality unknown within the state."),
    v("CODMUNRES", "fonte", "Município de residência do falecido, código IBGE de 6 dígitos.",
      "Municipality of residence of the deceased, 6-digit IBGE code.", "Não usado na análise.", "Not used in the analysis."),
    v("LOCOCOR", "fonte", "Tipo de local de ocorrência do óbito.", "Type of place where the death occurred.",
      "Ver os códigos abaixo. A análise usa 4 = via pública.", "See the codes below. The analysis uses 4 = public road."),
    v("CAUSABAS", "fonte", "Causa básica do óbito, CID-10, sem ponto.", "Underlying cause of death, ICD-10, without the dot.",
      "Ex. V031. Acidentes de transporte terrestre: V01–V89; agressões: X85–Y09.",
      "E.g. V031. Land-transport crashes: V01–V89; assaults: X85–Y09."),
    v("CIRCOBITO", "fonte", "Circunstância da morte não natural.", "Circumstance of a non-natural death.",
      "Ausente nas mortes naturais. Não usado na análise (a CID-10 define o desfecho).",
      "Missing for natural deaths. Not used in the analysis (the ICD-10 code defines the outcome)."),
    v("IDADE", "fonte", "Idade do falecido, codificada em 3 dígitos.", "Age of the deceased, coded in 3 digits.",
      "1º dígito = unidade (0 minutos, 1 horas, 2 dias, 3 meses, 4 anos, 5 = 100 anos ou mais, 9 ignorada); 2º e 3º = quantidade. Ex. 435 = 35 anos; 501 = 101 anos.",
      "1st digit = unit (0 minutes, 1 hours, 2 days, 3 months, 4 years, 5 = 100 years or more, 9 unknown); 2nd and 3rd = amount. E.g. 435 = 35 years; 501 = 101 years."),
    v("SEXO", "fonte", "Sexo do falecido.", "Sex of the deceased.", "1 masculino, 2 feminino, 0 ou 9 ignorado.",
      "1 male, 2 female, 0 or 9 unknown."),
    v("year_file", "projeto", "Ano do arquivo (ano do óbito).", "Year of the file (year of death)."),
    v("preliminary", "projeto", "TRUE se o ano veio do diretório PRELIM do DATASUS (dados preliminares).",
      "TRUE if the year came from the DATASUS PRELIM directory (preliminary data).",
      "A análise descarta os anos preliminares.", "The analysis drops preliminary years."),
    v("n_files", "projeto", "Número de arquivos .dbc empilhados no ano.", "Number of .dbc files stacked for the year.",
      "27 arquivos estaduais; 1 quando só o nacional (DOBR) existe.", "27 state files; 1 when only the national file (DOBR) exists.")),
  codes = rbind(
    cv("LOCOCOR", "1", "Hospital", "Hospital"),
    cv("LOCOCOR", "2", "Outro estabelecimento de saúde", "Other health facility"),
    cv("LOCOCOR", "3", "Domicílio", "Home"),
    cv("LOCOCOR", "4", "Via pública", "Public road"),
    cv("LOCOCOR", "5", "Outros", "Other"),
    cv("LOCOCOR", "6", "Aldeia indígena", "Indigenous village"),
    cv("LOCOCOR", "9", "Ignorado", "Unknown"),
    cv("LOCOCOR", "NA", "Ausente", "Missing"),
    cv("CAUSABAS", "V01–V09", "Pedestre", "Pedestrian", "CAUSABAS >= 'V01' AND CAUSABAS < 'V10'"),
    cv("CAUSABAS", "V10–V19", "Ciclista", "Cyclist", "CAUSABAS >= 'V10' AND CAUSABAS < 'V20'"),
    cv("CAUSABAS", "V20–V29", "Motociclista", "Motorcyclist", "CAUSABAS >= 'V20' AND CAUSABAS < 'V30'"),
    cv("CAUSABAS", "V30–V39", "Ocupante de triciclo motorizado", "Occupant of a motorised tricycle", "CAUSABAS >= 'V30' AND CAUSABAS < 'V40'"),
    cv("CAUSABAS", "V40–V49", "Ocupante de automóvel", "Car occupant", "CAUSABAS >= 'V40' AND CAUSABAS < 'V50'"),
    cv("CAUSABAS", "V50–V59", "Ocupante de caminhonete", "Occupant of a pick-up truck or van", "CAUSABAS >= 'V50' AND CAUSABAS < 'V60'"),
    cv("CAUSABAS", "V60–V69", "Ocupante de veículo de transporte pesado", "Occupant of a heavy transport vehicle", "CAUSABAS >= 'V60' AND CAUSABAS < 'V70'"),
    cv("CAUSABAS", "V70–V79", "Ocupante de ônibus", "Bus occupant", "CAUSABAS >= 'V70' AND CAUSABAS < 'V80'"),
    cv("CAUSABAS", "V80–V89", "Outros acidentes de transporte terrestre", "Other land-transport accidents", "CAUSABAS >= 'V80' AND CAUSABAS < 'V90'"),
    cv("CAUSABAS", "X85–Y09", "Agressões", "Assaults", "CAUSABAS >= 'X85' AND CAUSABAS < 'Y10'"),
    cv("CAUSABAS", "demais", "Todas as outras causas", "All other causes",
       "NOT ((CAUSABAS >= 'V01' AND CAUSABAS < 'V90') OR (CAUSABAS >= 'X85' AND CAUSABAS < 'Y10'))"),
    cv("CIRCOBITO", "1", "Acidente", "Accident"),
    cv("CIRCOBITO", "2", "Suicídio", "Suicide"),
    cv("CIRCOBITO", "3", "Homicídio", "Homicide"),
    cv("CIRCOBITO", "4", "Outros", "Other"),
    cv("CIRCOBITO", "9", "Ignorado", "Unknown"),
    cv("CIRCOBITO", "0", "Código inválido", "Invalid code"),
    cv("CIRCOBITO", "NA", "Ausente (morte natural)", "Missing (natural death)"),
    cv("IDADE", "0xx", "Minutos (menos de 1 hora)", "Minutes (under 1 hour)", "substr(IDADE, 1, 1) = '0'"),
    cv("IDADE", "1xx", "Horas", "Hours", "substr(IDADE, 1, 1) = '1'"),
    cv("IDADE", "2xx", "Dias", "Days", "substr(IDADE, 1, 1) = '2'"),
    cv("IDADE", "3xx", "Meses", "Months", "substr(IDADE, 1, 1) = '3'"),
    cv("IDADE", "4xx", "Anos (00–99)", "Years (00–99)", "substr(IDADE, 1, 1) = '4'"),
    cv("IDADE", "5xx", "100 anos ou mais (100 + xx)", "100 years or more (100 + xx)", "substr(IDADE, 1, 1) = '5'"),
    cv("IDADE", "9xx", "Ignorada", "Unknown", "substr(IDADE, 1, 1) = '9'"),
    cv("SEXO", "1", "Masculino", "Male"),
    cv("SEXO", "2", "Feminino", "Female"),
    cv("SEXO", "0", "Ignorado", "Unknown"),
    cv("SEXO", "9", "Ignorado", "Unknown"),
    cv("HORAOBITO", "hhmm", "Preenchida com 4 caracteres", "Filled in, 4 characters", "length(HORAOBITO) = 4"),
    cv("HORAOBITO", "outro", "Preenchida com outro comprimento (inválida)", "Filled in, other length (invalid)", "length(HORAOBITO) <> 4"),
    cv("HORAOBITO", "NA", "Ausente", "Missing"),
    cv("preliminary", "false", "Consolidado", "Final"),
    cv("preliminary", "true", "Preliminar", "Preliminary")))

# ── PRF ─────────────────────────────────────────────────────────────────────
fase_map <- c("pleno dia" = "Pleno dia|Full daylight", "plena noite" = "Plena noite|Full night",
              "anoitecer" = "Anoitecer|Dusk", "amanhecer" = "Amanhecer|Dawn")
class_map <- c("com vitimas feridas" = "Com vítimas feridas|With injured victims",
               "sem vitimas" = "Sem vítimas|No victims",
               "com vitimas fatais" = "Com vítimas fatais|With fatalities",
               "ignorado" = "Ignorado|Unknown")
weather_map <- c("ceu claro" = "Céu claro|Clear sky", "nublado" = "Nublado|Cloudy", "chuva" = "Chuva|Rain",
                 "sol" = "Sol|Sunny", "ignorada" = "Ignorada|Unknown", "ignorado" = "Ignorada|Unknown",
                 "garoachuvisco" = "Garoa ou chuvisco|Drizzle", "garoa/chuvisco" = "Garoa ou chuvisco|Drizzle",
                 "nevoeiro/neblina" = "Nevoeiro ou neblina|Fog or mist", "vento" = "Vento|Wind",
                 "granizo" = "Granizo|Hail", "neve" = "Neve|Snow")
type_map <- c(
  "colisao traseira" = "Colisão traseira|Rear-end collision",
  "colisao lateral" = "Colisão lateral|Side collision",
  "colisao lateral mesmo sentido" = "Colisão lateral, mesmo sentido|Side collision, same direction",
  "colisao lateral sentido oposto" = "Colisão lateral, sentido oposto|Side collision, opposite direction",
  "colisao transversal" = "Colisão transversal|Right-angle collision",
  "colisao frontal" = "Colisão frontal|Head-on collision",
  "colisao com objeto fixo" = "Colisão com objeto fixo|Collision with a fixed object",
  "colisao com objeto estatico" = "Colisão com objeto estático|Collision with a stationary object",
  "colisao com objeto" = "Colisão com objeto|Collision with an object",
  "colisao com objeto movel" = "Colisão com objeto em movimento|Collision with a moving object",
  "colisao com objeto em movimento" = "Colisão com objeto em movimento|Collision with a moving object",
  "colisao com bicicleta" = "Colisão com bicicleta|Collision with a bicycle",
  "saida de pista" = "Saída de pista|Run-off-road",
  "saida de leito carrocavel" = "Saída do leito carroçável|Left the carriageway",
  "tombamento" = "Tombamento|Tip-over",
  "capotamento" = "Capotamento|Rollover",
  "queda de motocicleta / bicicleta / veiculo" = "Queda de motocicleta, bicicleta ou veículo|Fall from a motorcycle, bicycle or vehicle",
  "queda de ocupante de veiculo" = "Queda de ocupante de veículo|Occupant fell from a vehicle",
  "atropelamento de pessoa" = "Atropelamento de pessoa|Person struck",
  "atropelamento de pedestre" = "Atropelamento de pedestre|Pedestrian struck",
  "atropelamento de animal" = "Atropelamento de animal|Animal struck",
  "incendio" = "Incêndio|Vehicle fire",
  "engavetamento" = "Engavetamento|Multi-vehicle pile-up",
  "danos eventuais" = "Danos eventuais|Incidental damage",
  "derramamento de carga" = "Derramamento de carga|Cargo spill",
  "eventos atipicos" = "Eventos atípicos|Atypical events",
  "sinistro pessoal de transito" = "Sinistro pessoal de trânsito|Personal traffic incident")
null_map <- setNames(c("Ausente|Missing", "Vazio|Empty", "Texto \"(null)\"|Text \"(null)\""), c("<NA>", "<EMPTY>", "(null)"))

D$prf_accidents <- list(
  family = "prf", file = "prf/output/prf_accidents.parquet", builder = "build/03_clean_prf.R",
  title_pt = "Acidentes em rodovias federais (PRF)", title_en = "Crashes on federal highways (PRF)",
  unit_pt = "Acidente atendido pela Polícia Rodoviária Federal.", unit_en = "Crash attended by the Federal Highway Police.",
  key = "year_file, id",
  coverage_pt = "2007 a 2025, rodovias federais, 27 UFs.", coverage_en = "2007 to 2025, federal highways, 27 states.",
  source_pt = "PRF, dados abertos, arquivos \"agrupados por ocorrência\" (um por ano). Rótulos de texto mudam de grafia entre anos e são mantidos como publicados.",
  source_en = "PRF open data, files \"grouped by occurrence\" (one per year). Text labels change spelling across years and are kept as published.",
  vars = rbind(
    v("year_file", "projeto", "Ano do arquivo da PRF; igual ao ano de date.", "Year of the PRF file; equal to the year of date."),
    v("id", "fonte", "Identificador do acidente na PRF.", "PRF crash identifier.", "Único dentro de year_file.", "Unique within year_file."),
    v("date", "fonte", "Data do acidente.", "Date of the crash.", "Padronizada de três formatos de origem.", "Harmonised from three source formats."),
    v("uf", "fonte", "Sigla da UF do acidente.", "State of the crash."),
    v("br", "fonte", "Número da rodovia federal (BR).", "Federal highway number (BR).", "Texto, ex. \"116\".", "Text, e.g. \"116\"."),
    v("km", "fonte", "Marco quilométrico do local do acidente.", "Kilometre marker of the crash site."),
    v("municipio", "fonte", "Município do acidente, como escrito pela PRF.", "Municipality of the crash, as written by the PRF.",
      "Maiúsculas, sem acento. A análise casa com o IBGE pelo nome dentro da UF, com build/manual/prf_municipio_alias.csv.",
      "Upper case, no accents. The analysis matches it to IBGE by name within state, with build/manual/prf_municipio_alias.csv."),
    v("fase_dia", "fonte", "Condição de luz anotada pelo agente.", "Light condition recorded by the officer.",
      "Em minúsculas. Ver os códigos abaixo.", "Lower-cased. See the codes below."),
    v("tipo_acidente", "fonte", "Tipo de acidente.", "Type of crash.",
      "A análise separa atropelamentos de pessoa ou pedestre dos demais.",
      "The analysis separates pedestrian strikes from the rest."),
    v("causa_acidente", "fonte", "Causa presumida do acidente.", "Presumed cause of the crash.",
      "Cerca de 100 rótulos; a lista mudou em 2017. Não usada na análise.",
      "About 100 labels; the list changed in 2017. Not used in the analysis."),
    v("condicao_metereologica", "fonte", "Condição meteorológica (nome da coluna como na PRF).",
      "Weather condition (column name as spelled by the PRF)."),
    v("classificacao", "fonte", "Classificação do acidente pela gravidade.", "Crash classification by severity.", "Em minúsculas.", "Lower-cased."),
    v("pessoas", "fonte", "Pessoas envolvidas.", "People involved."),
    v("mortos", "fonte", "Mortos no local do acidente.", "People killed at the crash scene.",
      "Definição da PRF (horario_verao/fontes_dados/prf_definicao_mortos.txt); mortes posteriores no hospital não entram.",
      "PRF definition (horario_verao/fontes_dados/prf_definicao_mortos.txt); later deaths in hospital are not counted."),
    v("feridos_graves", "fonte", "Feridos graves.", "Seriously injured."),
    v("feridos", "fonte", "Feridos, leves e graves.", "Injured, light and serious.", "Sempre ≥ feridos_graves.", "Always ≥ feridos_graves."),
    v("veiculos", "fonte", "Veículos envolvidos.", "Vehicles involved."),
    v("lat", "fonte", "Latitude do acidente, graus decimais.", "Latitude of the crash, decimal degrees.",
      "Só a partir de 2017. Não usada na análise.", "From 2017 only. Not used in the analysis."),
    v("lon", "fonte", "Longitude do acidente, graus decimais.", "Longitude of the crash, decimal degrees.",
      "Só a partir de 2017. Não usada na análise.", "From 2017 only. Not used in the analysis."),
    v("hour", "projeto", "Hora do acidente, 0–23, em hora legal local.", "Hour of the crash, 0–23, in local legal (clock) time.",
      "Do campo horario (hh:mm:ss). Que é hora legal está conferido em analysis/code/03_prf_clock_check.R.",
      "From the field horario (hh:mm:ss). That it is legal time is checked in analysis/code/03_prf_clock_check.R."),
    v("minute", "projeto", "Minuto do acidente, 0–59, em hora legal local.", "Minute of the crash, 0–59, in local legal (clock) time.")),
  codes = rbind(
    cv("classificacao", "*", "", "", "auto"),
    cv("fase_dia", "*", "", "", "auto"),
    cv("tipo_acidente", "*", "", "", "auto"),
    cv("condicao_metereologica", "*", "", "", "auto")),
  auto_maps = list(fase_dia = fase_map, classificacao = class_map,
                   condicao_metereologica = weather_map, tipo_acidente = type_map))

D$prf_persons <- list(
  family = "prf", file = "prf/output/prf_persons.parquet", builder = "build/11_prf_persons.R",
  title_pt = "Pessoas envolvidas em acidentes em rodovias federais (PRF)",
  title_en = "People involved in crashes on federal highways (PRF)",
  unit_pt = "Pessoa envolvida em um acidente.", unit_en = "Person involved in a crash.",
  key = "year_file, id, pesid",
  coverage_pt = "2007 a 2025. Liga a prf_accidents por (year_file, id).",
  coverage_en = "2007 to 2025. Links to prf_accidents by (year_file, id).",
  source_pt = "PRF, dados abertos, arquivos \"agrupados por pessoa\". Os mortos por acidente somam o mortos de prf_accidents (conferido pelo script).",
  source_en = "PRF open data, files \"grouped by person\". The dead per crash add up to mortos in prf_accidents (checked by the script).",
  vars = rbind(
    v("year_file", "projeto", "Ano do arquivo da PRF.", "Year of the PRF file."),
    v("id", "fonte", "Identificador do acidente na PRF.", "PRF crash identifier."),
    v("pesid", "fonte", "Identificador da pessoa na PRF.", "PRF person identifier."),
    v("role", "projeto", "Papel da pessoa no acidente.", "Role of the person in the crash.",
      "tipo_envolvido em minúsculas, sem acento. Ausente quando a linha não tem papel (2017 em diante).",
      "tipo_envolvido lower-cased, without accents. Missing when the row has no role (2017 onwards)."),
    v("state", "projeto", "Estado físico da pessoa.", "Physical state of the person.",
      "Padronizado de estado_fisico, cujos rótulos mudaram em 2017.", "Harmonised from estado_fisico, whose labels changed in 2017."),
    v("age", "projeto", "Idade em anos.", "Age in years.",
      "1–110; 0 vira ausente (a partir de 2017, 0 marca idade desconhecida).",
      "1–110; 0 becomes missing (from 2017, 0 marks unknown age)."),
    v("sex", "projeto", "Sexo.", "Sex.", "Ausente quando inválido, ignorado ou não informado.", "Missing when invalid, unknown or not reported.")),
  codes = rbind(
    cv("role", "condutor", "Condutor", "Driver"),
    cv("role", "passageiro", "Passageiro", "Passenger"),
    cv("role", "pedestre", "Pedestre", "Pedestrian"),
    cv("role", "testemunha", "Testemunha", "Witness"),
    cv("role", "cavaleiro", "Cavaleiro", "Horse rider"),
    cv("role", "ciclista", "Ciclista", "Cyclist"),
    cv("role", "vitima", "Vítima", "Victim"),
    cv("role", "autor", "Autor", "Perpetrator"),
    cv("role", "proprietario da cnh", "Proprietário da CNH", "Driving-licence holder"),
    cv("role", "proprietario de carga", "Proprietário de carga", "Cargo owner"),
    cv("role", "NA", "Sem papel", "No role"),
    cv("state", "dead", "Morto (Morto / Óbito)", "Dead"),
    cv("state", "serious", "Ferido grave", "Seriously injured"),
    cv("state", "light", "Ferido leve", "Lightly injured"),
    cv("state", "unhurt", "Ileso", "Unhurt"),
    cv("state", "unknown", "Ignorado ou outro", "Unknown or other"),
    cv("sex", "male", "Masculino", "Male"),
    cv("sex", "female", "Feminino", "Female"),
    cv("sex", "NA", "Ignorado", "Unknown")))

# ── PNCT ────────────────────────────────────────────────────────────────────
D$pnct_hourly <- list(
  family = "pnct", file = "pnct/output/pnct_hourly.parquet", builder = "build/07_clean_pnct.R",
  title_pt = "Volume de tráfego por hora (PNCT)", title_en = "Hourly traffic volume (PNCT)",
  unit_pt = "Estação de contagem × data × hora × sentido.", unit_en = "Count station × date × hour × direction.",
  key = "station, date, hour, dir",
  coverage_pt = "2014 a 2019 e 2021 a 2025 (2020 não foi publicado). Rodovias federais.",
  coverage_en = "2014 to 2019 and 2021 to 2025 (2020 was not published). Federal highways.",
  source_pt = "DNIT, Plano Nacional de Contagem de Tráfego, postos de contagem contínua (API do portal dadospnct).",
  source_en = "DNIT, National Traffic Count Plan, continuous count stations (dadospnct portal API).",
  vars = rbind(
    v("station", "projeto", "Estação de contagem: UF_BR_km.", "Count station: UF_BR_km.",
      "Ex. AL_101_126.49. O contrato de 2020 trocou os equipamentos e quase sempre o km, então nenhuma estação conta antes e depois da abolição.",
      "E.g. AL_101_126.49. The 2020 contract replaced the devices and almost always moved the km, so no station counts both before and after abolition."),
    v("date", "fonte", "Data da contagem.", "Count date."),
    v("imputed", "projeto", "TRUE se o dia da estação foi modelado pelo DNIT, não contado.",
      "TRUE if the station-day was modelled by DNIT, not counted.",
      "Total diário igual ao do mesmo dia da semana 1 a 4 semanas antes ou depois. Concentrado a partir de junho de 2019, fim do contrato. A análise descarta esses dias.",
      "Daily total equal to that of the same weekday 1 to 4 weeks before or after. Concentrated from June 2019, when the contract ended. The analysis drops these days."),
    v("uf", "fonte", "Sigla da UF da estação.", "State of the station."),
    v("br", "fonte", "Número da rodovia federal.", "Federal highway number."),
    v("km", "fonte", "Marco quilométrico da estação.", "Kilometre marker of the station."),
    v("lat", "fonte", "Latitude da estação, graus decimais.", "Latitude of the station, decimal degrees."),
    v("lon", "fonte", "Longitude da estação, graus decimais.", "Longitude of the station, decimal degrees."),
    v("hour", "fonte", "Hora do relógio da contagem, 0–23, em hora legal local.", "Clock hour of the count, 0–23, in local legal time.",
      "Hora h = de h:00 a h:59. Que é hora legal está conferido em analysis/code/15_traffic_volume.R.",
      "Hour h = from h:00 to h:59. That it is legal time is checked in analysis/code/15_traffic_volume.R."),
    v("dir", "fonte", "Sentido do tráfego.", "Direction of traffic.", "C = km crescente; D = km decrescente.",
      "C = increasing km; D = decreasing km."),
    v("heavy", "projeto", "Veículos pesados: classes A–H (ônibus e caminhões).", "Heavy vehicles: classes A–H (buses and trucks)."),
    v("light", "projeto", "Veículos leves: classes I (automóveis) e J (motocicletas).", "Light vehicles: classes I (cars) and J (motorcycles)."),
    v("undef", "fonte", "Veículos de classe indefinida (L).", "Vehicles of undefined class (L)."),
    v("total", "projeto", "Total de veículos: heavy + light + undef.", "All vehicles: heavy + light + undef.")),
  codes = rbind(
    cv("dir", "C", "Crescente", "Increasing km"), cv("dir", "D", "Decrescente", "Decreasing km"),
    cv("imputed", "false", "Contado", "Counted"), cv("imputed", "true", "Modelado pelo DNIT", "Modelled by DNIT")))

bins <- c(sprintf("eve%+d", -3:2), sprintf("morn%+d", -2:2))
D$pnct_station_day_bins <- list(
  family = "pnct", file = "pnct/output/pnct_station_day_bins.parquet", builder = "analysis/code/15_traffic_volume.R",
  title_pt = "Volume de tráfego por faixa de hora solar (PNCT)", title_en = "Traffic volume by solar-hour bin (PNCT)",
  unit_pt = "Estação × dia × faixa de 60 minutos relativa ao pôr ou ao nascer do sol.",
  unit_en = "Station × day × 60-minute bin relative to sunset or sunrise.",
  key = "station, date, key",
  coverage_pt = "Dias completos e contados (24 horas, sem dias modelados) nas janelas de verão e de inverno; temporadas 2013/14 a 2018/19 e 2020/21 a 2024/25; UFs tratadas e controles.",
  coverage_en = "Complete, counted days (24 hours, no modelled days) in the summer and off-season windows; seasons 2013/14 to 2018/19 and 2020/21 to 2024/25; treated and control states.",
  source_pt = "Construída a partir de pnct_hourly e guardada pela análise para 16_inference_volume.R e 25_total_cost.R.",
  source_en = "Built from pnct_hourly and saved by the analysis for 16_inference_volume.R and 25_total_cost.R.",
  vars = rbind(
    v("station", "projeto", "Estação de contagem: UF_BR_km.", "Count station: UF_BR_km."),
    v("date", "projeto", "Data.", "Date."),
    v("y", "projeto", "Veículos na faixa: soma dos dois sentidos e de todas as classes.", "Vehicles in the bin: both directions, all classes.",
      "Cada hora do relógio vai para a faixa que contém o seu ponto médio.", "Each clock hour goes to the bin that contains its midpoint."),
    v("uf", "projeto", "Sigla da UF da estação.", "State of the station."),
    v("window", "projeto", "Janela da temporada.", "Window of the season.",
      "win = 15/nov a 14/fev (horário de verão em todas as temporadas até 2018/19); off = 1º/abr a 31/ago (nunca horário de verão).",
      "win = 15 Nov to 14 Feb (DST in every season up to 2018/19); off = 1 Apr to 31 Aug (never DST)."),
    v("sy", "projeto", "Temporada, pelo primeiro ano (julho a junho).", "Season, by its first year (July to June).", "2018 = 2018/19.", "2018 = 2018/19."),
    v("treated", "projeto", "1 se a UF é tratada (horário de verão em todas as temporadas 2008/09–2018/19).",
      "1 if the state is treated (DST in every season 2008/09–2018/19).", "Ver a aba UFs.", "See the UFs sheet."),
    v("win", "projeto", "1 se window = win.", "1 if window = win."),
    v("post", "projeto", "1 se a temporada é posterior à abolição (sy > 2018).", "1 if the season follows abolition (sy > 2018)."),
    v("tw", "projeto", "treated × win.", "treated × win."),
    v("twp", "projeto", "treated × win × post: o regressor da diferença tripla.", "treated × win × post: the triple-difference regressor."),
    v("key", "projeto", "Faixa de 60 minutos em hora padrão.", "60-minute bin in standard time.",
      "eve0 = a hora seguinte ao pôr do sol em hora padrão (clara com horário de verão, escura sem); eve−3…eve+2 relativas ao pôr, morn−2…morn+2 ao nascer; rest = as outras 13 horas do dia.",
      "eve0 = the hour after standard-time sunset (light under DST, dark without); eve−3…eve+2 relative to sunset, morn−2…morn+2 to sunrise; rest = the other 13 hours of the day.")),
  codes = rbind(
    cv("window", "win", "15/nov a 14/fev", "15 Nov to 14 Feb"), cv("window", "off", "1º/abr a 31/ago", "1 Apr to 31 Aug"),
    rbindlist(lapply(bins, function(b) {
      side <- if (startsWith(b, "eve")) c("pôr", "sunset") else c("nascer", "sunrise")
      k <- as.integer(sub("^[a-z]+", "", b))
      cv("key", b, sprintf("De %d a %d min após o %s do sol (hora padrão)", 60 * k, 60 * (k + 1), side[1]),
         sprintf("%d to %d min after %s (standard time)", 60 * k, 60 * (k + 1), side[2]))
    })),
    cv("key", "rest", "As outras 13 horas do dia", "The other 13 hours of the day")))

D$pnct_download_log <- list(
  family = "pnct", file = "pnct/output/download_log.csv", builder = "build/06_download_pnct.R",
  title_pt = "Registro do download do PNCT", title_en = "PNCT download log",
  unit_pt = "Ano × UF (× BR, quando a UF foi baixada rodovia por rodovia).",
  unit_en = "Year × state (× highway, when the state was downloaded highway by highway).",
  key = "year, uf, br", coverage_pt = "Anos publicados no portal.", coverage_en = "Years published on the portal.",
  source_pt = "Escrito pelo script de download.", source_en = "Written by the download script.",
  vars = rbind(
    v("year", "projeto", "Ano pedido à API.", "Year requested from the API."),
    v("uf", "projeto", "UF pedida à API.", "State requested from the API."),
    v("br", "projeto", "Rodovia pedida, quando a UF foi dividida por BR.", "Highway requested, when the state was split by BR.",
      "Vazio quando a UF veio inteira.", "Empty when the state came whole."),
    v("status", "projeto", "Resultado do pedido.", "Outcome of the request.")),
  codes = rbind(
    cv("status", "ok", "Baixado agora", "Downloaded now"),
    cv("status", "here", "Já estava baixado", "Already downloaded"),
    cv("status", "empty", "Sem estação naquele ano e UF", "No station in that year and state"),
    cv("status", "failed", "Falhou", "Failed")))

# ── Weather ─────────────────────────────────────────────────────────────────
D$pr_seat_day <- list(
  family = "weather", file = "weather/output/pr_seat_day.parquet", builder = "build/08_xavier_rain.R",
  title_pt = "Chuva diária na sede municipal (Xavier)", title_en = "Daily rain at the municipal seat (Xavier)",
  unit_pt = "Sede municipal × dia.", unit_en = "Municipal seat × day.", key = "code6, date",
  coverage_pt = "1º/jul/2008 a 30/jun/2025; 5.569 sedes (Fernando de Noronha fica fora da grade).",
  coverage_en = "1 Jul 2008 to 30 Jun 2025; 5,569 seats (Fernando de Noronha is off the grid).",
  source_pt = "Xavier et al., BR-DWGD v3.2.4, grade diária de 0,1°; célula que contém a sede (NetCDF baixado à mão, em weather/input/).",
  source_en = "Xavier et al., BR-DWGD v3.2.4, 0.1° daily grid; the cell containing the seat (NetCDF downloaded by hand, in weather/input/).",
  vars = rbind(
    v("code6", "projeto", "Código IBGE de 6 dígitos (DATASUS).", "6-digit IBGE code (DATASUS)."),
    v("date", "fonte", "Data.", "Date."),
    v("pr_mm", "fonte", "Precipitação do dia, mm.", "Precipitation of the day, mm.",
      "Sedes costeiras que caem numa célula de mar usam a célula com dado mais próxima (até 0,3°).",
      "Coastal seats that fall in a sea cell use the nearest cell with data (up to 0.3°).")),
  codes = NULL)

# ── Hand-coded tables (build/manual/, versioned) ────────────────────────────
M <- list()
M$hv_temporadas <- list(
  family = "manual", file = "build/manual/hv_temporadas.csv", repo = TRUE, builder = "à mão · by hand",
  title_pt = "Temporadas de horário de verão", title_en = "DST seasons",
  unit_pt = "Temporada (34).", unit_en = "Season (34).", key = "temporada",
  coverage_pt = "1985/86 a 2018/19.", coverage_en = "1985/86 to 2018/19.",
  source_pt = "Decretos no Planalto; fonte do tratamento. Lido por build/01_dst_calendar.R.",
  source_en = "Decrees at planalto.gov.br; the source of treatment. Read by build/01_dst_calendar.R.",
  vars = rbind(
    v("temporada", "manual", "Temporada, aaaa/aa.", "Season, yyyy/yy."),
    v("inicio", "manual", "Início nacional (00:00 local).", "National start (00:00 local time)."),
    v("fim", "manual", "Fim nacional; o dia já é horário padrão.", "National end; that day is already standard time."),
    v("ufs", "manual", "UFs com horário de verão.", "States with DST.", "Siglas separadas por espaço, ou TODAS.", "Abbreviations separated by spaces, or TODAS (all)."),
    v("atos", "manual", "Atos legais.", "Legal acts."),
    v("verificacao", "manual", "Como as datas foram conferidas (planalto, regra, parcial).", "How the dates were verified (planalto, regra, parcial)."),
    v("nota", "manual", "Observação.", "Note.")),
  codes = NULL)
M$hv_excecoes <- list(
  family = "manual", file = "build/manual/hv_excecoes.csv", repo = TRUE, builder = "à mão · by hand",
  title_pt = "Saídas no meio da temporada", title_en = "Mid-season exits",
  unit_pt = "UF × temporada com datas próprias.", unit_en = "State × season with dates of its own.", key = "temporada, uf",
  coverage_pt = "2000/01 (PE e RR após 1 semana; o resto do Nordeste após 2).", coverage_en = "2000/01 (PE and RR after 1 week; the rest of the Northeast after 2).",
  source_pt = "Decretos 3.630/2000 e 3.632/2000.", source_en = "Decrees 3,630/2000 and 3,632/2000.",
  vars = rbind(
    v("temporada", "manual", "Temporada.", "Season."), v("uf", "manual", "Sigla da UF.", "State abbreviation."),
    v("inicio_uf", "manual", "Início na UF.", "Start in the state."),
    v("fim_uf", "manual", "Fim na UF; o dia já é horário padrão.", "End in the state; that day is already standard time."),
    v("ato", "manual", "Ato legal.", "Legal act."), v("nota", "manual", "Observação.", "Note.")),
  codes = NULL)
M$fusos_mudancas <- list(
  family = "manual", file = "build/manual/fusos_mudancas.csv", repo = TRUE, builder = "à mão · by hand",
  title_pt = "Mudanças de fuso horário", title_en = "Time-zone changes",
  unit_pt = "Mudança de fuso de uma área.", unit_en = "Time-zone change of an area.", key = "area, vigencia",
  coverage_pt = "2008 e 2013.", coverage_en = "2008 and 2013.",
  source_pt = "Leis 11.662/2008 e 12.876/2013.", source_en = "Laws 11,662/2008 and 12,876/2013.",
  vars = rbind(
    v("area", "manual", "Área que mudou de fuso.", "Area whose time zone changed."),
    v("de_utc", "manual", "Offset UTC padrão antes, horas.", "Standard UTC offset before, hours."),
    v("para_utc", "manual", "Offset UTC padrão depois, horas.", "Standard UTC offset after, hours."),
    v("vigencia", "manual", "Data em que o novo fuso entrou em vigor.", "Date the new zone took effect."),
    v("ato", "manual", "Ato legal.", "Legal act."),
    v("verificacao", "manual", "Como foi conferido.", "How it was verified."),
    v("nota", "manual", "Observação.", "Note.")),
  codes = NULL)
M$prf_municipio_alias <- list(
  family = "manual", file = "build/manual/prf_municipio_alias.csv", repo = TRUE, builder = "à mão · by hand",
  title_pt = "Nomes de município da PRF que não batem com o IBGE", title_en = "PRF municipality names that do not match IBGE",
  unit_pt = "Nome de município na PRF.", unit_en = "Municipality name in the PRF data.", key = "uf, municipio_prf",
  coverage_pt = "Casos encontrados no casamento por nome.", coverage_en = "Cases found when matching by name.",
  source_pt = "Conferência manual contra o IBGE.", source_en = "Checked by hand against IBGE.",
  vars = rbind(
    v("uf", "manual", "Sigla da UF.", "State abbreviation."),
    v("municipio_prf", "manual", "Nome como escrito pela PRF.", "Name as written by the PRF."),
    v("code6", "manual", "Código IBGE de 6 dígitos correspondente.", "Matching 6-digit IBGE code."),
    v("nome_ibge", "manual", "Nome no IBGE.", "Name at IBGE."),
    v("nota", "manual", "Por que não bate.", "Why it does not match.")),
  codes = NULL)
M$prf_files <- list(
  family = "manual", file = "build/manual/prf_files.csv", repo = TRUE, builder = "à mão · by hand",
  title_pt = "Arquivos de acidentes da PRF no Google Drive", title_en = "PRF crash files on Google Drive",
  unit_pt = "Ano.", unit_en = "Year.", key = "year", coverage_pt = "2007 a 2025.", coverage_en = "2007 to 2025.",
  source_pt = "Lidos da página de dados abertos da PRF; usados por build/02_download_prf.R.",
  source_en = "Read off the PRF open-data page; used by build/02_download_prf.R.",
  vars = rbind(v("year", "manual", "Ano do arquivo.", "Year of the file."),
               v("drive_id", "manual", "Identificador do arquivo no Google Drive.", "Google Drive file id.")),
  codes = NULL)
M$prf_person_files <- list(
  family = "manual", file = "build/manual/prf_person_files.csv", repo = TRUE, builder = "à mão · by hand",
  title_pt = "Arquivos de pessoas da PRF no Google Drive", title_en = "PRF person files on Google Drive",
  unit_pt = "Ano.", unit_en = "Year.", key = "year", coverage_pt = "2007 a 2025.", coverage_en = "2007 to 2025.",
  source_pt = "Lidos da página de dados abertos da PRF; usados por build/11_prf_persons.R.",
  source_en = "Read off the PRF open-data page; used by build/11_prf_persons.R.",
  vars = rbind(v("year", "manual", "Ano do arquivo.", "Year of the file."),
               v("drive_id", "manual", "Identificador do arquivo no Google Drive.", "Google Drive file id.")),
  codes = NULL)

# ── Profile every dataset from the data ─────────────────────────────────────
con <- dbConnect(duckdb())
on.exit(dbDisconnect(con, shutdown = TRUE), add = TRUE)

TYPE <- c(VARCHAR = "character", INTEGER = "integer", BIGINT = "integer", SMALLINT = "integer",
          TINYINT = "integer", DOUBLE = "double", FLOAT = "double", DATE = "date",
          BOOLEAN = "logical", TIMESTAMP = "datetime")

relation <- function(d, id) {
  path <- if (isTRUE(d$repo)) here::here(d$file) else file.path(B, if (is.null(d$glob)) d$file else d$glob)
  files <- Sys.glob(path)
  if (!length(files)) return(NULL)
  rel <- switch(tools::file_ext(path),
    parquet = sprintf("read_parquet('%s', union_by_name = true)", path),
    csv     = sprintf("read_csv_auto('%s', header = true)", path),
    gpkg    = {
      g <- sf::st_read(path, quiet = TRUE)
      d$geom_col <- attr(g, "sf_column")
      duckdb_register(con, id, sf::st_drop_geometry(g))
      sprintf('"%s"', id)
    })
  list(rel = rel, files = files, geom_col = d$geom_col)
}

fmt_val <- function(x) {
  if (is.null(x) || is.na(x)) return("")
  if (inherits(x, "Date")) return(format(x))
  if (is.numeric(x)) return(if (x != round(x)) format(signif(x, 6), scientific = FALSE)
                            else format(x, big.mark = if (abs(x) >= 1e4) "," else "", scientific = FALSE))
  as.character(x)
}

profile <- function(rel, n) {
  cols <- dbGetQuery(con, sprintf("DESCRIBE SELECT * FROM %s", rel))[, c("column_name", "column_type")]
  rbindlist(lapply(seq_len(nrow(cols)), function(i) {
    c0 <- cols$column_name[i]; ty <- sub("\\(.*", "", cols$column_type[i])
    q <- sprintf('"%s"', c0)
    ordered <- ty %in% c("INTEGER", "BIGINT", "SMALLINT", "TINYINT", "DOUBLE", "FLOAT", "DATE", "DECIMAL")
    s <- dbGetQuery(con, sprintf("SELECT count(%s) AS k, count(DISTINCT %s) AS u %s FROM %s", q, q,
                                 if (ordered) sprintf(", min(%s) AS lo, max(%s) AS hi", q, q) else "", rel))
    top <- ""
    if (!ordered || s$u <= 30) {
      if (s$u <= 0.5 * n || s$u <= 30) {
        t <- dbGetQuery(con, sprintf("SELECT %s AS v, count(*) AS n FROM %s WHERE %s IS NOT NULL
                                      GROUP BY 1 ORDER BY 2 DESC, 1 LIMIT 3", q, rel, q))
        # Values that each hold under 0.5% of rows say nothing about the variable.
        top <- if (!nrow(t)) "" else if (t$n[1] < 0.005 * n) "muitos valores · many values"
               else paste(sprintf("%s (%.1f%%)", vapply(t$v, fmt_val, ""), 100 * t$n / n), collapse = " · ")
      } else top <- "identificador · identifier"
    }
    data.table(variable = c0, type = if (is.na(TYPE[ty])) tolower(ty) else unname(TYPE[ty]), missing = 1 - s$k / n,
               distinct = as.numeric(s$u),
               lo = if (ordered) fmt_val(s$lo) else "", hi = if (ordered) fmt_val(s$hi) else "", top = top)
  }))
}

code_freq <- function(d, rel, n) {
  if (is.null(d$codes)) return(NULL)
  fixed <- d$codes[cond != "auto"]
  fixed[, n_obs := vapply(cond, function(cnd)
    dbGetQuery(con, sprintf("SELECT count(*) AS n FROM %s WHERE %s", rel, cnd))$n, numeric(1))]
  auto <- rbindlist(lapply(d$codes[cond == "auto", variable], function(var) {
    t <- as.data.table(dbGetQuery(con, sprintf('SELECT "%s" AS v, count(*) AS n FROM %s GROUP BY 1', var, rel)))
    t[, k := norm(v)]
    map <- c(d$auto_maps[[var]], null_map)
    t[, lab := unname(map[k])]
    if (anyNA(t$lab)) {
      warning(var, ": no translation for ", paste(unique(t[is.na(lab), v]), collapse = "; "))
      t[is.na(lab), lab := paste0(v, "|(sem tradução)")]
    }
    t[, c("pt", "en") := tstrsplit(lab, "|", fixed = TRUE)]
    t[, show := fifelse(is.na(v), "NA", fifelse(v == "", "\"\"", v))]
    t[order(-n), .(value = paste(show, collapse = " · "), pt = pt[1], n_obs = sum(n)), by = en][
      order(-n_obs), .(variable = var, value, pt, en, cond = "auto", n_obs)]
  }))
  out <- rbind(fixed, auto)
  out[, share := n_obs / n]
  out[, variable := factor(variable, levels = unique(d$codes$variable))]
  out[order(variable)][, variable := as.character(variable)][]
}

# Analysis and build scripts that read each file, found by its name.
scripts <- c(list.files(here::here("analysis", "code"), "\\.R$", full.names = TRUE),
             list.files(here::here("build"), "\\.R$", full.names = TRUE))
code_txt <- setNames(lapply(scripts, readLines, warn = FALSE), scripts)
used_by <- function(d) {
  pat <- if (!is.null(d$glob)) "path_sim_out|sim_years\\(" else basename(d$file)
  hit <- names(code_txt)[vapply(code_txt, function(x) any(grepl(pat, x, fixed = is.null(d$glob))), logical(1))]
  hit <- setdiff(hit, here::here(d$builder))
  hit <- hit[!grepl("00_utils|00_master", hit)]
  if (!length(hit)) return("—")
  dirs <- sub(paste0(here::here(), "/"), "", dirname(hit))
  paste(vapply(unique(dirs), function(dd) sprintf("%s/: %s", dd,
    paste(sub("\\.R$", "", basename(hit[dirs == dd])), collapse = ", ")), ""), collapse = "  |  ")
}

run <- function(d, id) {
  r <- relation(d, id)
  if (is.null(r)) { warning(id, ": file not found, skipped"); return(NULL) }
  n <- dbGetQuery(con, sprintf("SELECT count(*) AS n FROM %s", r$rel))$n
  p <- profile(r$rel, n)
  if (!is.null(r$geom_col))
    p <- rbind(p, data.table(variable = r$geom_col, type = "geometry", missing = 0, distinct = n,
                             lo = "", hi = "", top = ""))
  undocumented <- setdiff(p$variable, d$vars$variable)
  absent <- setdiff(d$vars$variable, p$variable)
  if (length(undocumented) || length(absent))
    stop(id, ": dictionary out of date. Not described: ", paste(undocumented, collapse = ", "),
         " | Described but absent: ", paste(absent, collapse = ", "))
  d$vars <- p[d$vars, on = "variable"]
  d$codes <- code_freq(d, r$rel, n)
  d$n <- n; d$ncol <- nrow(p); d$mb <- sum(file.size(r$files)) / 1e6
  d$n_files <- length(r$files); d$used <- used_by(d); d$id <- id
  message(sprintf("%-24s %12s rows  %3d cols", id, format(n, big.mark = ","), d$ncol))
  d
}
D <- Filter(Negate(is.null), Map(run, D, names(D)))
M <- Filter(Negate(is.null), Map(run, M, names(M)))

# ── States ──────────────────────────────────────────────────────────────────
uf_names <- c(RO = "Rondônia", AC = "Acre", AM = "Amazonas", RR = "Roraima", PA = "Pará", AP = "Amapá",
              TO = "Tocantins", MA = "Maranhão", PI = "Piauí", CE = "Ceará", RN = "Rio Grande do Norte",
              PB = "Paraíba", PE = "Pernambuco", AL = "Alagoas", SE = "Sergipe", BA = "Bahia",
              MG = "Minas Gerais", ES = "Espírito Santo", RJ = "Rio de Janeiro", SP = "São Paulo",
              PR = "Paraná", SC = "Santa Catarina", RS = "Rio Grande do Sul", MS = "Mato Grosso do Sul",
              MT = "Mato Grosso", GO = "Goiás", DF = "Distrito Federal")
region <- function(code) c(`1` = "Norte · North", `2` = "Nordeste · Northeast", `3` = "Sudeste · Southeast",
                           `4` = "Sul · South", `5` = "Centro-Oeste · Centre-West")[as.character(code %/% 10)]
excl <- list(BA = c("Excluída: horário de verão só em 2011/12", "Excluded: DST in 2011/12 only"),
             TO = c("Excluída: horário de verão só em 2012/13", "Excluded: DST in 2012/13 only"),
             AC = c("Excluída: mudou de fuso em 2008 e 2013", "Excluded: time zone changed in 2008 and 2013"),
             AM = c("Excluída: oeste mudou de fuso em 2008 e 2013", "Excluded: west changed time zone in 2008 and 2013"))
offset_txt <- c(AC = "−5 (−4 de 24/06/2008 a 10/11/2013)", AM = "−4 (13 municípios do sudoeste: −5)",
                PA = "−3 (oeste: −4 até 24/06/2008)", PE = "−3 (Fernando de Noronha: −2)",
                MS = "−4", MT = "−4", RO = "−4", RR = "−4")
season <- as.data.table(dbGetQuery(con, sprintf(
  "SELECT uf, sum((status <> 'out')::int) AS n FROM read_parquet('%s') WHERE temporada >= '2008/09' GROUP BY uf",
  file.path(B, "calendar/output/dst_uf_season.parquet"))))
munis <- as.data.table(dbGetQuery(con, sprintf("SELECT uf, count(*) AS n FROM read_parquet('%s') GROUP BY uf",
                                               file.path(B, "geo/output/muni_geo.parquet"))))
ufs <- data.table(code = unname(UF_CODE[UFS]), uf = UFS, name = unname(uf_names[UFS]))
ufs[, region := region(code)]
ufs[, group := fcase(uf %in% TREATED, "Tratada · Treated", uf %in% CONTROL, "Controle · Control",
                     default = "Excluída · Excluded")]
ufs[, why_pt := fcase(uf %in% TREATED, "Horário de verão em todas as temporadas de 2008/09 a 2018/19",
                      uf %in% CONTROL, "Sem horário de verão de 2008/09 a 2018/19", default = "")]
ufs[, why_en := fcase(uf %in% TREATED, "DST in every season from 2008/09 to 2018/19",
                      uf %in% CONTROL, "No DST from 2008/09 to 2018/19", default = "")]
for (u in names(excl)) ufs[uf == u, `:=`(why_pt = excl[[u]][1], why_en = excl[[u]][2])]
ufs[, offset := fifelse(uf %in% names(offset_txt), offset_txt[uf], "−3")]
ufs[season, on = "uf", seasons := i.n]
ufs[munis, on = "uf", n_muni := i.n]

# ── Workbook ────────────────────────────────────────────────────────────────
wb <- createWorkbook(creator = "DaylightSaving")
modifyBaseFont(wb, fontSize = 10, fontName = "Calibri")
NAVY <- "#1F3864"; NAVY2 <- "#2F5597"; GRID <- "#D9D9D9"; ZEBRA <- "#F5F8FC"; INK <- "#262626"
ORIGIN <- list(fonte   = list(fill = "#E2EFDA", ink = "#375623", label = "Fonte · Source"),
               projeto = list(fill = "#FCE4D6", ink = "#843C0C", label = "Projeto · Project"),
               manual  = list(fill = "#FFF2CC", ink = "#7F6000", label = "Manual · Hand-coded"))
LAST <- 12L          # columns A:L in the dataset sheets

st <- function(fontColour = INK, ...) createStyle(fontColour = fontColour, valign = "top", wrapText = TRUE, ...)
s_title    <- createStyle(fontSize = 18, textDecoration = "bold", fontColour = NAVY)
s_sub      <- createStyle(fontSize = 11, fontColour = "#595959", textDecoration = "italic")
s_head     <- createStyle(fontSize = 10, fontColour = "#FFFFFF", fgFill = NAVY, textDecoration = "bold",
                          halign = "center", valign = "center", wrapText = TRUE,
                          border = "TopBottomLeftRight", borderColour = "#FFFFFF")
s_group    <- createStyle(fontSize = 10, fontColour = "#FFFFFF", fgFill = NAVY2, textDecoration = "bold",
                          halign = "center", valign = "center", border = "TopBottomLeftRight", borderColour = "#FFFFFF")
s_label    <- createStyle(fontSize = 10, fontColour = "#404040", fgFill = "#EDEDED", textDecoration = "bold",
                          valign = "top", wrapText = TRUE, border = "Bottom", borderColour = "#FFFFFF")
s_info     <- st(border = "Bottom", borderColour = "#EDEDED")
s_info_en  <- st(border = "Bottom", borderColour = "#EDEDED", fontColour = "#404040", textDecoration = "italic")
cell <- function(fill = "#FFFFFF", fontColour = INK, ...)
  createStyle(fontColour = fontColour, valign = "top", wrapText = TRUE, fgFill = fill,
              border = "TopBottomLeftRight", borderColour = GRID, ...)
s_var   <- function(fill) cell(fill, fontName = "Consolas", textDecoration = "bold", fontColour = NAVY)
s_mid   <- function(fill) cell(fill, halign = "center", fontColour = "#595959")
s_pct   <- function(fill) cell(fill, halign = "right", numFmt = "0.0%")
s_int   <- function(fill) cell(fill, halign = "right", numFmt = "#,##0")
s_en    <- function(fill) cell(fill, fontColour = "#404040", textDecoration = "italic")
s_chip  <- lapply(ORIGIN, function(o) createStyle(fgFill = o$fill, fontColour = o$ink, halign = "center",
                                                  valign = "top", textDecoration = "bold", fontSize = 9,
                                                  border = "TopBottomLeftRight", borderColour = GRID))

band <- function(sheet, row, text, fill, cols = 1:LAST, size = 13, height = 28, ink = "#FFFFFF") {
  writeData(wb, sheet, text, startCol = cols[1], startRow = row)
  mergeCells(wb, sheet, cols = cols, rows = row)
  addStyle(wb, sheet, createStyle(fontSize = size, fontColour = ink, fgFill = fill, textDecoration = "bold",
                                  valign = "center", indent = 1), rows = row, cols = cols, gridExpand = TRUE)
  setRowHeights(wb, sheet, row, height)
}
# Approximate wrapped height of a merged cell, which Excel does not autofit.
lines_h <- function(text, width_chars) 14 * max(1, ceiling(nchar(text) / width_chars))
tint <- function(hex, a = 0.15) {
  rgb <- col2rgb(hex) / 255
  do.call(grDevices::rgb, as.list(1 - a * (1 - rgb)))
}

# ── Dataset blocks ──────────────────────────────────────────────────────────
anchor <- list()     # sheet and row of each dataset, for links
write_block <- function(sheet, d, row) {
  fam <- FAMILY[[d$family]]
  anchor[[d$id]] <<- c(sheet = sheet, row = row)
  band(sheet, row, sprintf("%s   ·   %s   ·   %s", basename(d$file), d$title_pt, d$title_en), fam)
  where <- if (isTRUE(d$repo)) paste0("GitHub: ", d$file) else paste0("Dropbox: DROPBOX_ROOT/build/", d$file)
  size <- sprintf("%s linhas · rows   |   %d colunas · columns   |   %s MB%s",
                  format(d$n, big.mark = ","), d$ncol, format(round(d$mb, 1), nsmall = 1),
                  if (d$n_files > 1) sprintf("   |   %d arquivos · files", d$n_files) else "")
  info <- list(
    c("Arquivo · File", where, NA), c("Gerado por · Built by", d$builder, NA),
    c("Unidade · Unit", d$unit_pt, d$unit_en), c("Chave · Key", d$key, NA),
    c("Cobertura · Coverage", d$coverage_pt, d$coverage_en),
    c("Fonte · Source", d$source_pt, d$source_en), c("Tamanho · Size", size, NA),
    c("Usado em · Used by", d$used, NA))
  r <- row + 1L
  for (x in info) {
    writeData(wb, sheet, x[1], startCol = 1, startRow = r)
    addStyle(wb, sheet, s_label, rows = r, cols = 1)
    if (is.na(x[3])) {
      writeData(wb, sheet, x[2], startCol = 2, startRow = r)
      mergeCells(wb, sheet, cols = 2:LAST, rows = r)
      addStyle(wb, sheet, s_info, rows = r, cols = 2:LAST, gridExpand = TRUE)
      setRowHeights(wb, sheet, r, lines_h(x[2], 230))
    } else {
      writeData(wb, sheet, x[2], startCol = 2, startRow = r)
      writeData(wb, sheet, x[3], startCol = 6, startRow = r)
      mergeCells(wb, sheet, cols = 2:5, rows = r)
      mergeCells(wb, sheet, cols = 6:LAST, rows = r)
      addStyle(wb, sheet, s_info, rows = r, cols = 2:5, gridExpand = TRUE)
      addStyle(wb, sheet, s_info_en, rows = r, cols = 6:LAST, gridExpand = TRUE)
      setRowHeights(wb, sheet, r, max(lines_h(x[2], 105), lines_h(x[3], 120)))
    }
    r <- r + 1L
  }

  # Variables
  r <- r + 1L
  groups <- list(list("Variável · Variable", 1:3), list("Português", 4:5), list("English", 6:7),
                 list("Perfil na base inteira · Profile of the full data", 8:12))
  for (g in groups) {
    writeData(wb, sheet, g[[1]], startCol = g[[2]][1], startRow = r)
    mergeCells(wb, sheet, cols = g[[2]], rows = r)
  }
  addStyle(wb, sheet, s_group, rows = r, cols = 1:LAST, gridExpand = TRUE)
  heads <- c("Variável", "Origem · Origin", "Tipo · Type", "Descrição", "Valores e notas", "Description",
             "Values and notes", "% ausente · missing", "Distintos · Distinct", "Mínimo · Min", "Máximo · Max",
             "Mais frequentes · Most frequent")
  writeData(wb, sheet, t(heads), startCol = 1, startRow = r + 1L, colNames = FALSE)
  addStyle(wb, sheet, s_head, rows = r + 1L, cols = 1:LAST, gridExpand = TRUE)
  setRowHeights(wb, sheet, r + 1L, 30)
  r <- r + 2L
  vt <- d$vars
  out <- vt[, .(variable, origin = vapply(origin, function(o) ORIGIN[[o]]$label, ""), type, pt, pt_note,
                en, en_note, missing, distinct, lo, hi, top)]
  writeData(wb, sheet, out, startCol = 1, startRow = r, colNames = FALSE)
  rows <- r + seq_len(nrow(out)) - 1L
  for (i in seq_along(rows)) {
    fill <- if (i %% 2 == 0) ZEBRA else "#FFFFFF"
    addStyle(wb, sheet, s_var(fill), rows = rows[i], cols = 1)
    addStyle(wb, sheet, s_chip[[vt$origin[i]]], rows = rows[i], cols = 2)
    addStyle(wb, sheet, s_mid(fill), rows = rows[i], cols = 3)
    addStyle(wb, sheet, cell(fill), rows = rows[i], cols = c(4, 5, 12), gridExpand = TRUE)
    addStyle(wb, sheet, s_en(fill), rows = rows[i], cols = 6:7, gridExpand = TRUE)
    addStyle(wb, sheet, s_pct(fill), rows = rows[i], cols = 8)
    addStyle(wb, sheet, s_int(fill), rows = rows[i], cols = 9)
    addStyle(wb, sheet, s_mid(fill), rows = rows[i], cols = 10:11, gridExpand = TRUE)
  }
  conditionalFormatting(wb, sheet, cols = 8, rows = rows, type = "databar", style = c("#F4B183", "#F4B183"),
                        rule = c(0, 1), gradient = FALSE, border = FALSE)
  r <- max(rows) + 2L

  # Codes
  if (!is.null(d$codes) && nrow(d$codes)) {
    band(sheet, r, "Códigos e frequências na base inteira · Codes and frequencies in the full data",
         tint(fam, 0.25), size = 11, height = 22, ink = INK)
    hc <- c("Variável", "Valor · Value", "", "Rótulo", "", "Label", "", "% das linhas · of rows", "N")
    writeData(wb, sheet, t(hc), startCol = 1, startRow = r + 1L, colNames = FALSE)
    for (cc in list(2:3, 4:5, 6:7)) mergeCells(wb, sheet, cols = cc, rows = r + 1L)
    addStyle(wb, sheet, s_head, rows = r + 1L, cols = 1:9, gridExpand = TRUE)
    setRowHeights(wb, sheet, r + 1L, 30)
    cd <- d$codes
    r0 <- r + 2L
    cd[, first := !duplicated(variable)]
    cd[, grp := cumsum(first)]
    for (i in seq_len(nrow(cd))) {
      rr <- r0 + i - 1L
      writeData(wb, sheet, if (cd$first[i]) cd$variable[i] else "", startCol = 1, startRow = rr)
      writeData(wb, sheet, cd$value[i], startCol = 2, startRow = rr)
      writeData(wb, sheet, cd$pt[i], startCol = 4, startRow = rr)
      writeData(wb, sheet, cd$en[i], startCol = 6, startRow = rr)
      writeData(wb, sheet, cd$share[i], startCol = 8, startRow = rr)
      writeData(wb, sheet, cd$n_obs[i], startCol = 9, startRow = rr)
      for (cc in list(2:3, 4:5, 6:7)) mergeCells(wb, sheet, cols = cc, rows = rr)
      fill <- if (cd$grp[i] %% 2 == 0) ZEBRA else "#FFFFFF"
      addStyle(wb, sheet, s_var(fill), rows = rr, cols = 1)
      addStyle(wb, sheet, cell(fill), rows = rr, cols = 2:5, gridExpand = TRUE)
      addStyle(wb, sheet, s_en(fill), rows = rr, cols = 6:7, gridExpand = TRUE)
      addStyle(wb, sheet, s_pct(fill), rows = rr, cols = 8)
      addStyle(wb, sheet, s_int(fill), rows = rr, cols = 9)
      setRowHeights(wb, sheet, rr, max(lines_h(cd$value[i], 30), lines_h(cd$pt[i], 55), lines_h(cd$en[i], 55)))
    }
    crow <- r0 + seq_len(nrow(cd)) - 1L
    conditionalFormatting(wb, sheet, cols = 8, rows = crow, type = "databar", style = c("#9DC3E6", "#9DC3E6"),
                          rule = c(0, 1), gradient = FALSE, border = FALSE)
    r <- max(crow) + 2L
  }
  r + 1L
}

dataset_sheet <- function(name, blocks, tab) {
  addWorksheet(wb, name, gridLines = FALSE, tabColour = tab)
  setColWidths(wb, name, cols = 1:LAST, widths = c(24, 13, 10, 42, 42, 42, 42, 11, 11, 13, 13, 38))
  r <- 1L
  for (d in blocks) r <- write_block(name, d, r)
}

# ── Dataset sheets ──────────────────────────────────────────────────────────
for (d in D) dataset_sheet(d$id, list(d), FAMILY[[d$family]])
dataset_sheet("manual", M, FAMILY[["manual"]])

# ── Leia-me · Read me ───────────────────────────────────────────────────────
s1 <- "Leia-me · Read me"
addWorksheet(wb, s1, gridLines = FALSE, tabColour = NAVY)
setColWidths(wb, s1, cols = 1:3, widths = c(3, 78, 78))
writeData(wb, s1, "Dicionário de dados · Data dictionary", startCol = 2, startRow = 2)
addStyle(wb, s1, s_title, rows = 2, cols = 2)
setRowHeights(wb, s1, 2, 30)
writeData(wb, s1, "DaylightSaving: o fim do horário de verão no Brasil e as mortes no trânsito · the end of daylight saving time in Brazil and road deaths",
          startCol = 2, startRow = 3)
addStyle(wb, s1, s_sub, rows = 3, cols = 2)
readme <- list(
  list("Sobre · About",
       "Este arquivo descreve todas as bases que o projeto constrói: o calendário legal do horário de verão, os óbitos do SIM, os acidentes e as pessoas da PRF, o volume de tráfego do PNCT, a chuva do Xavier, a iluminação pública do Censo e a geografia municipal. O projeto estima o efeito do fim do horário de verão (Decreto 9.772/2019) sobre as mortes no trânsito.",
       "This file describes every dataset the project builds: the legal DST calendar, SIM death certificates, PRF crashes and people, PNCT traffic volume, Xavier rainfall, Census street lighting and municipal geography. The project estimates the effect of the end of daylight saving time in Brazil (Decree 9,772/2019) on road deaths."),
  list("Onde estão os dados · Where the data live",
       "Os microdados ficam no Dropbox, em DROPBOX_ROOT/build/<fonte>/output/ (DROPBOX_ROOT é definido em config/config.R), e nunca entram no git. A exceção é build/manual/, o calendário digitado dos decretos, versionado no repositório. Cada base é escrita por um script de build/, indicado na sua aba.",
       "Microdata live in Dropbox, under DROPBOX_ROOT/build/<source>/output/ (DROPBOX_ROOT is set in config/config.R), and never enter git. The exception is build/manual/, the calendar typed from the decrees, versioned in the repository. Each dataset is written by a script in build/, named on its sheet."),
  list("Como ler · How to read",
       "Bases: uma linha por arquivo, com link para a aba dele. Variáveis: todas as variáveis numa lista só, com filtro, para buscar pelo nome. Uma aba por base: a ficha do arquivo, as variáveis (descrição, valores e o perfil calculado na base inteira) e, quando há, os códigos com as suas frequências. manual: as tabelas digitadas à mão. UFs: as 27 unidades da federação, com código IBGE, grupo na análise e fuso.",
       "Datasets: one row per file, linked to its sheet. Variables: every variable in a single filterable list, to search by name. One sheet per dataset: the file card, the variables (description, values and the profile computed on the full data) and, where there are any, the codes with their frequencies. manual: the hand-coded tables. UFs: the 27 states, with IBGE code, analysis group and time zone."),
  list("Relógios · Clocks",
       "Hora legal local (a do relógio, com horário de verão quando vigente), hora padrão local (sem horário de verão) e UTC são coisas diferentes. Toda hora do dia nas bases está em hora legal local: HORAOBITO no SIM, hour e minute na PRF, hour no PNCT. As três foram conferidas: o perfil por hora não se desloca uma hora com o horário de verão. A hora padrão do pôr e do nascer do sol é calculada na análise (analysis/code/00_utils.R) com o std_offset_h de muni_geo. AC e o sudoeste do AM passaram de UTC−5 para UTC−4 em 24/06/2008 e voltaram em 10/11/2013; o oeste do PA passou de UTC−4 para UTC−3 em 2008 e ficou.",
       "Local legal (clock) time, with DST when in force, local standard time (without DST) and UTC are different things. Every time of day in the data is local legal time: HORAOBITO in SIM, hour and minute in PRF, hour in PNCT. All three were checked: the hourly profile does not shift by an hour under DST. Standard-time sunset and sunrise are computed in the analysis (analysis/code/00_utils.R) with std_offset_h from muni_geo. AC and south-western AM moved from UTC−5 to UTC−4 on 24 Jun 2008 and back on 10 Nov 2013; western PA moved from UTC−4 to UTC−3 in 2008 and stayed."),
  list("Convenções · Conventions",
       "Temporada: de julho a junho, nomeada pelos dois anos (2018/19) ou pelo primeiro (sy = 2018). Um dia tem horário de verão quando início ≤ data < fim: a troca é à 00:00 e o dia do fim já é horário padrão. code7 é o código IBGE de 7 dígitos; code6, sem o dígito verificador, é o usado pelo DATASUS. Célula vazia é valor ausente. Rótulos de texto da PRF ficam como publicados, com as grafias de cada ano; os códigos agrupam as grafias de uma mesma categoria.",
       "Season: July to June, named by its two years (2018/19) or its first (sy = 2018). A day has DST when start ≤ date < end: clocks change at 00:00 and the end day is already standard time. code7 is the 7-digit IBGE code; code6, without the check digit, is the one DATASUS uses. An empty cell is a missing value. PRF text labels are kept as published, with each year's spelling; the codes group the spellings of one category."),
  list("Atualização · Updating",
       sprintf("Gerado por dictionary/build_dictionary.R em %s. Para atualizar: Rscript dictionary/build_dictionary.R. As descrições estão digitadas no script; o perfil e as frequências são lidos dos dados a cada execução. O script para se uma base ganhar ou perder uma variável sem que o dicionário seja atualizado.", format(Sys.Date(), "%d/%m/%Y")),
       sprintf("Generated by dictionary/build_dictionary.R on %s. To update: Rscript dictionary/build_dictionary.R. Descriptions are typed in the script; the profile and frequencies are read from the data on every run. The script stops if a dataset gains or loses a variable without the dictionary being updated.", format(Sys.Date(), "%Y-%m-%d"))))
r <- 5L
for (sec in readme) {
  band(s1, r, sec[[1]], NAVY2, cols = 2:3, size = 11, height = 22)
  writeData(wb, s1, sec[[2]], startCol = 2, startRow = r + 1L)
  writeData(wb, s1, sec[[3]], startCol = 3, startRow = r + 1L)
  addStyle(wb, s1, st(), rows = r + 1L, cols = 2)
  addStyle(wb, s1, st(fontColour = "#404040", textDecoration = "italic"), rows = r + 1L, cols = 3)
  setRowHeights(wb, s1, r + 1L, max(lines_h(sec[[2]], 100), lines_h(sec[[3]], 105)) + 6)
  r <- r + 3L
}
band(s1, r, "Origem da variável · Origin of the variable", NAVY2, cols = 2:3, size = 11, height = 22)
legend <- list(
  fonte = c("Publicada pela fonte; no máximo renomeada ou com o formato padronizado.",
            "Published by the source; at most renamed or reformatted."),
  projeto = c("Construída pelos scripts do projeto.", "Built by the project's scripts."),
  manual = c("Digitada à mão dos atos legais ou das páginas das fontes.", "Typed by hand from legal acts or source pages."))
for (o in names(legend)) {
  r <- r + 1L
  writeData(wb, s1, sprintf("%s  —  %s", ORIGIN[[o]]$label, legend[[o]][1]), startCol = 2, startRow = r)
  writeData(wb, s1, legend[[o]][2], startCol = 3, startRow = r)
  addStyle(wb, s1, createStyle(fgFill = ORIGIN[[o]]$fill, fontColour = ORIGIN[[o]]$ink, valign = "center",
                               border = "Bottom", borderColour = "#FFFFFF"), rows = r, cols = 2:3, gridExpand = TRUE)
  setRowHeights(wb, s1, r, 20)
}

# ── Bases · Datasets ────────────────────────────────────────────────────────
s2 <- "Bases · Datasets"
addWorksheet(wb, s2, gridLines = FALSE, tabColour = NAVY)
all_sets <- c(D, M)
sheet_of <- function(d) if (d$family == "manual") "manual" else d$id
idx <- rbindlist(lapply(all_sets, function(d) data.table(
  fam = "", sheet = sheet_of(d), file = d$file, title_pt = d$title_pt, title_en = d$title_en,
  unit_pt = d$unit_pt, unit_en = d$unit_en, rows = d$n, cols = d$ncol, mb = round(d$mb, 1),
  builder = d$builder, used = d$used)))
heads2 <- c("", "Aba · Sheet", "Arquivo · File", "Conteúdo", "Content", "Unidade de observação", "Unit of observation",
            "Linhas · Rows", "Colunas · Cols", "MB", "Gerado por · Built by", "Usado em · Used by")
writeData(wb, s2, "Bases · Datasets", startCol = 2, startRow = 1)
addStyle(wb, s2, s_title, rows = 1, cols = 2)
setRowHeights(wb, s2, 1, 30)
writeData(wb, s2, t(heads2), startCol = 1, startRow = 3, colNames = FALSE)
addStyle(wb, s2, s_head, rows = 3, cols = 1:12, gridExpand = TRUE)
setRowHeights(wb, s2, 3, 30)
writeData(wb, s2, idx, startCol = 1, startRow = 4, colNames = FALSE)
for (i in seq_len(nrow(idx))) {
  rr <- 3L + i
  d <- all_sets[[i]]
  a <- anchor[[d$id]]
  writeFormula(wb, s2, makeHyperlinkString(sheet = a[["sheet"]], row = as.integer(a[["row"]]), col = 1,
                                           text = idx$sheet[i]), startCol = 2, startRow = rr)
  fill <- if (i %% 2 == 0) ZEBRA else "#FFFFFF"
  addStyle(wb, s2, createStyle(fgFill = FAMILY[[d$family]]), rows = rr, cols = 1)
  addStyle(wb, s2, cell(fill, fontColour = "#0563C1", textDecoration = c("bold", "underline")), rows = rr, cols = 2)
  addStyle(wb, s2, cell(fill, fontName = "Consolas", fontSize = 9), rows = rr, cols = 3)
  addStyle(wb, s2, cell(fill), rows = rr, cols = c(4, 6, 11, 12), gridExpand = TRUE)
  addStyle(wb, s2, s_en(fill), rows = rr, cols = c(5, 7), gridExpand = TRUE)
  addStyle(wb, s2, s_int(fill), rows = rr, cols = 8:9, gridExpand = TRUE)
  addStyle(wb, s2, cell(fill, halign = "right", numFmt = "#,##0.0"), rows = rr, cols = 10)
}
setColWidths(wb, s2, cols = 1:12, widths = c(1.5, 22, 34, 30, 30, 30, 30, 12, 9, 8, 26, 34))
freezePane(wb, s2, firstActiveRow = 4, firstActiveCol = 3)

# ── Variáveis · Variables ───────────────────────────────────────────────────
s3 <- "Variáveis · Variables"
addWorksheet(wb, s3, gridLines = FALSE, tabColour = NAVY)
flat <- rbindlist(lapply(all_sets, function(d) d$vars[, .(sheet = sheet_of(d), file = basename(d$file), variable,
  origin = vapply(origin, function(o) ORIGIN[[o]]$label, ""), o = origin, type, pt, en, missing, fam = d$family, id = d$id)]))
heads3 <- c("Base · Dataset", "Arquivo · File", "Variável · Variable", "Origem · Origin", "Tipo · Type",
            "Descrição", "Description", "% ausente · missing")
writeData(wb, s3, t(heads3), startCol = 1, startRow = 1, colNames = FALSE)
addStyle(wb, s3, s_head, rows = 1, cols = 1:8, gridExpand = TRUE)
setRowHeights(wb, s3, 1, 30)
writeData(wb, s3, flat[, .(sheet, file, variable, origin, type, pt, en, missing)], startCol = 1, startRow = 2, colNames = FALSE)
for (i in seq_len(nrow(flat))) {
  rr <- i + 1L
  a <- anchor[[flat$id[i]]]
  writeFormula(wb, s3, makeHyperlinkString(sheet = a[["sheet"]], row = as.integer(a[["row"]]), col = 1,
                                           text = flat$sheet[i]), startCol = 1, startRow = rr)
  fill <- if (i %% 2 == 0) ZEBRA else "#FFFFFF"
  addStyle(wb, s3, cell(fill, fontColour = FAMILY[[flat$fam[i]]], textDecoration = "bold"), rows = rr, cols = 1)
  addStyle(wb, s3, cell(fill, fontName = "Consolas", fontSize = 9, fontColour = "#595959"), rows = rr, cols = 2)
  addStyle(wb, s3, s_var(fill), rows = rr, cols = 3)
  addStyle(wb, s3, s_chip[[flat$o[i]]], rows = rr, cols = 4)
  addStyle(wb, s3, s_mid(fill), rows = rr, cols = 5)
  addStyle(wb, s3, cell(fill), rows = rr, cols = 6)
  addStyle(wb, s3, s_en(fill), rows = rr, cols = 7)
  addStyle(wb, s3, s_pct(fill), rows = rr, cols = 8)
}
conditionalFormatting(wb, s3, cols = 8, rows = 1L + seq_len(nrow(flat)), type = "databar", style = c("#F4B183", "#F4B183"),
                      rule = c(0, 1), gradient = FALSE, border = FALSE)
setColWidths(wb, s3, cols = 1:8, widths = c(22, 28, 24, 18, 10, 60, 60, 12))
addFilter(wb, s3, rows = 1, cols = 1:8)
freezePane(wb, s3, firstActiveRow = 2, firstActiveCol = 4)

# ── UFs ─────────────────────────────────────────────────────────────────────
s4 <- "UFs"
addWorksheet(wb, s4, gridLines = FALSE, tabColour = NAVY)
heads4 <- c("Código IBGE · IBGE code", "UF", "Nome · Name", "Região · Region", "Grupo · Group", "Motivo",
            "Reason", "Temporadas com horário de verão, 2008/09–2018/19 · DST seasons",
            "Hora padrão (UTC) · Standard time (UTC)", "Municípios · Municipalities")
writeData(wb, s4, t(heads4), startCol = 1, startRow = 1, colNames = FALSE)
addStyle(wb, s4, s_head, rows = 1, cols = 1:10, gridExpand = TRUE)
setRowHeights(wb, s4, 1, 44)
writeData(wb, s4, ufs[, .(code, uf, name, region, group, why_pt, why_en, seasons, offset, n_muni)],
          startCol = 1, startRow = 2, colNames = FALSE)
GROUP_FILL <- c("Tratada · Treated" = "#F8CBAD", "Controle · Control" = "#BDD7EE", "Excluída · Excluded" = "#E7E6E6")
for (i in seq_len(nrow(ufs))) {
  rr <- i + 1L
  fill <- if (i %% 2 == 0) ZEBRA else "#FFFFFF"
  addStyle(wb, s4, s_mid(fill), rows = rr, cols = 1)
  addStyle(wb, s4, s_var(fill), rows = rr, cols = 2)
  addStyle(wb, s4, cell(fill), rows = rr, cols = c(3, 4, 6, 9), gridExpand = TRUE)
  addStyle(wb, s4, s_en(fill), rows = rr, cols = 7)
  addStyle(wb, s4, cell(GROUP_FILL[[ufs$group[i]]], textDecoration = "bold", halign = "center"), rows = rr, cols = 5)
  addStyle(wb, s4, s_int(fill), rows = rr, cols = c(8, 10), gridExpand = TRUE)
}
setColWidths(wb, s4, cols = 1:10, widths = c(11, 6, 22, 24, 20, 46, 46, 18, 32, 14))
freezePane(wb, s4, firstActiveRow = 2, firstActiveCol = 3)
addFilter(wb, s4, rows = 1, cols = 1:10)

# The dataset sheets were written first, so that the index sheets could link
# to the row where each dataset starts; the index sheets go to the front.
n_sh <- length(names(wb))
worksheetOrder(wb) <- c((n_sh - 3L):n_sh, seq_len(n_sh - 4L))
activeSheet(wb) <- s1
saveWorkbook(wb, out_path, overwrite = TRUE)
message("Wrote ", out_path)
