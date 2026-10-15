# =============================================================================
# 25_total_cost.R
#
# How many deaths per summer, and what are they worth?
#
# (1) Deaths. The net excess of the darkness-dose model (23_light_dose.R,
#     clock-hour x date effects), which sums every hour of the day weighted by
#     how much its light changed, per summer window and per DST season of the
#     2017 rule; the sum of the three hours of 11_reallocation.R is carried
#     alongside. These count only on-road deaths with a recorded clock time.
#     Two scale factors, from SIM land-transport deaths (V01-V89) in the
#     treated states, summer window, seasons before abolition:
#       f_time   on-road deaths / on-road deaths with a valid clock time
#       f_place  all transport deaths (any place) / on-road deaths
#     Three counts per summer:
#       A  on-road, with a clock time (the estimate itself; a lower bound)
#       B  A x f_time: on-road deaths, assuming deaths without a time come from
#          the dark hours in the same proportion as those with one
#       C  B x f_place: all transport deaths, assuming deaths in hospital come
#          from crashes in the dark hours in the same proportion as deaths on
#          the road. C is an extrapolation, not an estimate.
#
# (2) Value. Value of a statistical life by the reference approach of
#     Robinson, Hammitt & O'Keeffe (2019, J. Benefit-Cost Analysis 10(S1):
#     15-50), read in the source (PMC7473065, 12/10/2026):
#       (a) preferred default: US VSL-to-GNI-per-capita ratio of 160,
#           extrapolated with income elasticity 1.5, floor of 20 x GNI pc;
#       (b) 160 x GNI pc (elasticity 1.0; "likely a high-end estimate");
#       (c) 100 x GNI pc (OECD ratio, elasticity 1.0).
#     GNI per capita, PPP, current international $, 2025, the latest year
#     (World Bank WDI NY.GNP.PCAP.PP.CD, last updated 08/10/2026, API read
#     12/10/2026): Brazil 22,670; United States 89,490. PPP conversion factor,
#     GDP, Brazil 2025 (PA.NUS.PPP): 2.55441 BRL per international $. Values
#     in 2025 reais.
#       (d) the IPEA social cost of a death on a federal highway, a human-
#           capital cost (mostly lost production), not a willingness to pay:
#           R$ 433,286.69 per person killed in a fatal crash, December 2014
#           prices (Ipea/PRF 2015, "Acidentes de transito nas rodovias federais
#           brasileiras: caracterizacao, tendencias e custos para a sociedade",
#           Relatorio de Pesquisa, Table 6A, "Mortos", total; read in the PDF
#           12/10/2026). The 2016 update of the same series (Ipea, "Estimativa
#           dos custos dos acidentes de transito no Brasil com base na
#           atualizacao simplificada das pesquisas anteriores do Ipea",
#           Relatorio de Pesquisa, 2016, Table 1A) repeats the value; no later
#           Ipea cost per death was found. Brought to December 2025 by the IPCA
#           number index (IBGE SIDRA table 1737, variable 2266): 4,059.86
#           (Dec 2014) and 7,403.29 (Dec 2025).
# =============================================================================

source(here::here("config", "config.R"))
source(here::here("analysis", "code", "00_utils.R"))

SEASONS <- season_range()
days <- make_days(SEASONS)

GNI_PC_BRA <- 22670; GNI_PC_USA <- 89490; PPP_BRL <- 2.55441
vsl_intl <- c(
  "(a) elasticity 1.5 from the US ratio of 160" =
    max(160 * GNI_PC_USA * (GNI_PC_BRA / GNI_PC_USA)^1.5, 20 * GNI_PC_BRA),
  "(b) 160 x GNI per capita" = 160 * GNI_PC_BRA,
  "(c) 100 x GNI per capita" = 100 * GNI_PC_BRA)
IPEA_DEATH_2014 <- 433286.69; IPCA_2014_12 <- 4059.86; IPCA_2025_12 <- 7403.29
vsl <- rbind(
  data.table(rule = names(vsl_intl), vsl_intl_usd = unname(vsl_intl),
             vsl_brl_million = unname(vsl_intl) * PPP_BRL / 1e6),
  data.table(rule = "(d) IPEA social cost of a death (human capital)", vsl_intl_usd = NA_real_,
             vsl_brl_million = IPEA_DEATH_2014 * IPCA_2025_12 / IPCA_2014_12 / 1e6))
vsl[, ratio_to_gni := vsl_brl_million * 1e6 / PPP_BRL / GNI_PC_BRA]

# ── Scale factors ───────────────────────────────────────────────────────────
sim <- rbindlist(lapply((min(SEASONS)):(max(SEASONS) + 1L), function(y)
  as.data.table(read_parquet(file.path(path_sim_out, sprintf("sim_%d.parquet", y)),
                             col_select = c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "LOCOCOR",
                                            "CAUSABAS", "preliminary")))))
stopifnot(!any(sim$preliminary))
sim <- sim[CAUSABAS >= "V01" & CAUSABAS < "V90"]
sim[, `:=`(uf = code_to_uf[substr(CODMUNOCOR, 1, 2)], date = as.IDate(DTOBITO, format = "%d%m%Y"))]
sim <- days[, .(uf, date, tw, post)][sim, on = .(uf, date), nomatch = 0]
base <- sim[tw == 1L & post == 0L]
n_all <- nrow(base); n_road <- base[LOCOCOR %in% "4", .N]
n_road_time <- base[LOCOCOR %in% "4" & !is.na(clock_min(HORAOBITO)), .N]
f_time <- n_road / n_road_time; f_place <- n_all / n_road
n_pre <- sum(SEASONS <= LAST_PRE)
scale <- data.table(f_time = f_time, f_place = f_place,
                    all_transport_deaths_per_summer_pre = n_all / n_pre,
                    on_road_per_summer_pre = n_road / n_pre,
                    on_road_with_time_per_summer_pre = n_road_time / n_pre)

# ── Deaths and value per summer ─────────────────────────────────────────────
ex <- readRDS(file.path(path_audit, "reallocation.rds"))$sums[outcome == "SIM transport deaths, on road"]
dz <- readRDS(file.path(path_audit, "light_dose.rds"))$dose[outcome == "SIM transport deaths, on road" &
                                                             spec == "main"]
stopifnot(nrow(dz) == 1L)
base_counts <- data.table(
  sum = c("dose model, summer window", "dose model, DST season (2017 rule)",
          "net: evening 0, +1 and morning 0"),
  excess = c(dz$net, dz$season_net, ex[sum == "net: evening 0, +1 and morning 0", excess_per_season]),
  excess_se = c(dz$net_se, dz$season_net_se, ex[sum == "net: evening 0, +1 and morning 0", se]))
SUMS <- base_counts$sum
deaths <- rbindlist(lapply(SUMS, function(k) {
  x <- base_counts[sum == k]
  data.table(sum = k,
             count = c("A on road, with clock time", "B on road", "C all transport deaths"),
             deaths = x$excess * c(1, f_time, f_time * f_place),
             se = x$excess_se * c(1, f_time, f_time * f_place))
}))
deaths[, share_of_summer_transport_deaths_pct := 100 * deaths / scale$all_transport_deaths_per_summer_pre]
value <- CJ(sum = SUMS, count = unique(deaths$count), rule = vsl$rule, sorted = FALSE)
value <- deaths[value, on = .(sum, count)][vsl, on = "rule"]
value[, `:=`(value_brl_million = deaths * vsl_brl_million, value_se_brl_million = se * vsl_brl_million)]

saveRDS(list(scale = scale, deaths = deaths, vsl = vsl, value = value,
             inputs = list(GNI_PC_BRA = GNI_PC_BRA, GNI_PC_USA = GNI_PC_USA, PPP_BRL = PPP_BRL,
                           IPEA_DEATH_2014 = IPEA_DEATH_2014, IPCA_2014_12 = IPCA_2014_12,
                           IPCA_2025_12 = IPCA_2025_12)),
        file.path(path_audit, "total_cost.rds"))
options(width = 180)
print(scale); print(vsl); print(deaths)
print(value[sum == SUMS[1], .(count, rule, deaths = round(deaths), value_brl_million = round(value_brl_million))])
