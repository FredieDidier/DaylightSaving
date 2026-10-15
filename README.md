# Replication package: *Darker Evenings: Road Deaths after Brazil Abolished Daylight Saving Time*

Author: Fredie Didier. Manuscript in `latex/` (submitted to *AEJ: Economic Policy*).

This README follows the template of the Social Science Data Editors (version 1.1),
which the AEA Data Editor recommends.

## Overview

The code builds the data from public sources and then estimates the effect of
Brazil's abolition of daylight saving time (Decree 9,772 of 25 April 2019) on
road deaths in the clock hour that turned dark, with a replication on Mexico's
abolition of 2022. It is written in R and has three entry points:
`config/00_master_build.R` builds the data (12 scripts), `analysis/code/00_master_analysis.R`
estimates everything and writes every figure and table (30 scripts), and `latex/build.sh`
compiles the paper and the Online Appendix. The main text has 4 figures and 7 tables
and the Online Appendix has 10 figures and 7 tables, all produced by the code. The
analysis takes about 2 to 3 hours on an 8-core laptop; rebuilding the data from
scratch takes longer, mostly in downloads.

## Data availability and provenance statements

### Statement about rights

- [x] I certify that the author of the manuscript has legitimate access to and permission to use the data used in this manuscript.
- [ ] I certify that the author has documented permission to redistribute/publish the data contained within this replication package.

Every source is public and free of charge. The second box is not checked because
documented permission to redistribute has not been confirmed for every source; the
last column of the table below gives the status of each. The two sources whose terms
forbid redistribution (GADM) or state no terms (BR-DWGD) are not in the package:
a script downloads the first, and the second is downloaded by hand from the URL given.

### License for data

To be set at deposit. Files derived by the author are released under the default
license of the repository (CC BY 4.0 on openICPSR); third-party data keep their own terms.

### Summary of availability

- [x] All data **are** publicly available.
- [ ] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

### Details on each data source

| Data | Citation | Script | Access | In the package |
|---|---|---|---|---|
| Legal DST calendar, 1985–2019 | decrees, e.g. Brasil (2008, 2019) | `build/01` | typed by hand from the decrees on planalto.gov.br; texts in `horario_verao/fontes_legais/` | yes, `build/manual/*.csv` |
| Death register (SIM), 2008–2024 | Ministério da Saúde (2025) | `build/05` | DATASUS FTP, `ftp.datasus.gov.br/dissemin/publicos/SIM/`, no registration | cleaned extract (`sim/output`); raw files re-downloaded by the script |
| Federal highway crashes (PRF), 2007–2025 | Polícia Rodoviária Federal (2025) | `build/02`, `03` | open data page of the PRF; file ids in `build/manual/prf_files.csv` | cleaned extract (`prf/output`); raw files re-downloaded by the script |
| Hourly traffic counts (PNCT), 2014–2019 and 2021–2025 | DNIT (2025) | `build/06`, `07` | public API of `servicos.dnit.gov.br/dadospnct` (routes in the script header) | cleaned extract (`pnct/output`); raw files re-downloaded by the script |
| Municipal seats and state boundaries | IBGE (2020), via the R package `geobr` | `build/04`, `12` | downloaded by `geobr` | yes (`geo/output`) |
| Daily rain grid BR-DWGD v3.2.4 | Xavier et al. (2022) | `build/08` | manual download of `pr_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc` from <https://sites.google.com/site/alexandrecandidoxavierufes/brazilian-daily-weather-gridded-data>; no license stated | no (2.6 GB raw grid); the derived file `weather/output/pr_seat_day.parquet` is included |
| Census 2022 (street lighting, table 9839) and Census 2010 (tract surroundings) | IBGE (2011, 2023) | `build/09` | SIDRA API; Census 2010 through the R package `censobr` | yes (`census/input`, `census/output`) |
| Population of the states, Census 2022 (table 4709) | IBGE (2023) | none: quoted in Section I | SIDRA | the two totals are in the text |
| Mexican road crashes (ATUS), 1997–2025 | INEGI (2026a) | `build/11` | open data zip, <https://www.inegi.org.mx/contenidos/programas/accidentes/datosabiertos/conjunto_de_datos_atus_anual_csv.zip> (release of 28/08/2026) | yes (`mexico/input/atus_raw`) |
| Mexican municipal seats | INEGI (2026b) | `build/10` | INEGI geostatistical web service | yes (`mexico/input/inegi_geo`) |
| Mexican boundaries, GADM 4.1 | GADM (2022) | `build/12` | downloaded by `geodata::gadm`; free for academic use, redistribution not allowed without permission | no; downloaded by the script |
| Country outlines for the maps | Natural Earth (n.d.) | `analysis/code/29` | R packages `rnaturalearth`, `rnaturalearthdata`; public domain | read from the R package |
| GNI per head and PPP conversion factor, 2025 | World Bank (2026) | `analysis/code/25` | WDI series NY.GNP.PCAP.PP.CD and PA.NUS.PPP; CC BY 4.0 | values written in the script |
| Consumer price index (IPCA) | IBGE (2026) | `analysis/code/25` | SIDRA table 1737 | values written in the script |
| Social cost of a death on a federal highway | Ipea and PRF (2015), Table 6A | `analysis/code/25` | public report | value written in the script |
| Sunrise and sunset | NOAA (n.d.); Meeus (1998) | `analysis/code/00_utils.R` | equations, no data | — |

The death register is revised by DATASUS, so a fresh download of a year may differ
slightly from the extract in the package. The most recent year (2025) is flagged as
preliminary by the build and never enters the analysis.

## Dataset list

Every data file lives under one folder, `DROPBOX_ROOT/build/`, with `DROPBOX_ROOT` set in
`config/config.R`. In the package these files are under `data/build/`.

| File | Written by | Content | Provided |
|---|---|---|---|
| `calendar/output/dst_uf_season.parquet`, `dst_uf_day.parquet` | `build/01` | DST status by state and season, and by state and day | yes |
| `sim/output/sim_<year>.parquet` (2008–2025) | `build/05` | death certificates, selected columns | yes |
| `prf/output/prf_accidents.parquet` | `build/03` | one row per federal highway crash, 2007–2025 | yes |
| `geo/output/muni_geo.parquet`, `br_states.gpkg` | `build/04`, `12` | municipal seats with time zone; state boundaries | yes |
| `pnct/output/pnct_hourly.parquet`, `pnct_station_day_bins.parquet`, `download_log.csv` | `build/06`, `07`, `analysis/code/15` | hourly vehicle counts by station | yes |
| `weather/output/pr_seat_day.parquet` | `build/08` | daily rain at each municipal seat | yes |
| `census/input/*`, `census/output/muni_lighting.parquet` | `build/09` | share of households on unlit streets by municipality | yes |
| `mexico/input/atus_raw/`, `mexico/input/inegi_geo/` | INEGI; `build/10` | raw ATUS zip; cached responses of the INEGI web service | yes |
| `mexico/output/atus_accidents.parquet`, `mx_muni_geo.parquet` | `build/10`, `11` | one row per Mexican crash; municipal seats | yes |
| `mexico/output/mx_states.gpkg`, `mx_border_states_munis.gpkg`, `mexico/input/gadm/` | `build/12` | GADM boundaries | no (GADM terms) |
| `audit/events_sun_bins.parquet`, `audit/*.rds` | `analysis/code/01`–`28` | event file and the cached estimates that `29` and `30` read | yes |

All files are Parquet, GeoPackage, CSV, JSON or R's `.rds`; each build script describes
its output in its header.

## Computational requirements

### Software requirements

- R 4.4.2. `Rscript config/00_setup.R` installs every package. Versions used:
  `data.table` 1.18.2.1, `arrow` 21.0.0, `fixest` 0.12.1, `fwildclusterboot` 0.14.3
  (r-universe), `dqrng` 0.4.1, `HonestDiD` 0.2.8 (GitHub, commit 6813f02), `ggplot2` 4.0.2,
  `patchwork` 1.3.0, `ragg` 1.5.0, `sf` 1.1-0, `terra` 1.8-50, `geobr` 2.0.0,
  `geodata` 0.6-6, `rnaturalearth` 1.2.0, `rnaturalearthdata` 1.0.0.9000 (r-universe),
  `censobr` 0.2.0 (GitHub, commit 429440f), `read.dbc` 1.2.0 (GitHub, commit 52e0b15),
  `RCurl` 1.98-1.16, `curl` 6.1.0, `jsonlite` 2.0.0, `dplyr` 1.2.0, `here` 1.0.1.
- TeX Live 2024 (`pdflatex`, `bibtex`); the AEA template (`AEA.cls`, `aea.bst`) is in `latex/`.
- `unzip` on the command line (read by `build/11`).
- Tested on macOS 26.6. The parallel steps use `parallel::mclapply`, which forks;
  on Windows they run on one core.

### Controlled randomness

- [x] Random seeds are set at the top of every script that draws:
  `analysis/code/05_imputation.R` line 37, `06_inference.R` lines 40–41,
  `09_within_day.R` line 51, `14_inference_pedestrian.R` lines 28–29,
  `16_inference_volume.R` line 40, `26_mexico.R` lines 51–52.
  All draws are made before the work is split across cores, so results do not
  depend on the number of cores.

### Memory, runtime, storage requirements

#### Summary

Approximate time needed to reproduce the analyses on a standard (2026) desktop machine:

- [ ] <10 minutes
- [ ] 10–60 minutes
- [ ] 1–2 hours
- [x] 2–8 hours (analysis from the data in the package)
- [ ] 8–24 hours
- [ ] 1–3 days
- [ ] Not feasible to run on a desktop machine

Approximate storage space needed: 3.3 GB with the raw rain grid, 0.7 GB without it.

#### Details

The code was last run on an Apple M1 Pro laptop (8 cores, 16 GB of memory, macOS 26.6),
with the default of 5 worker processes. The analysis takes about 2 to 3 hours, most of it
in the permutation and bootstrap draws of `05`, `06`, `14`, `16` and `26`; this
figure comes from the timestamps of the cached results, not from one uninterrupted run.
Rebuilding the data adds the downloads of `build/02`, `05`, `06` and `10`, which depend on
the remote servers and resume where they stopped.

## Description of programs/code

```
config/config.R           paths; DROPBOX_ROOT is the only line to edit
config/00_setup.R         installs the R packages
config/00_master_build.R  runs build/01-12 in order
build/manual/             legal DST calendar typed from the decrees; PRF file ids;
                          PRF municipality name aliases
build/01                  treatment calendar by state, season and day
build/02-03               PRF crashes: download, clean
build/04                  municipal seats and standard time zones
build/05                  SIM death certificates
build/06-07               PNCT traffic counts: download, clean
build/08                  rain at each municipal seat (BR-DWGD)
build/09                  street lighting, Census 2022 and 2010
build/10-11               Mexico: municipal seats, ATUS crashes
build/12                  boundaries for the two maps
analysis/code/00_utils.R  shared definitions: groups, windows, solar equations, panel
analysis/code/00_master_analysis.R   runs 01-30 in order, each in its own R process
analysis/code/01-28       one estimate each, cached in DROPBOX_ROOT/build/audit/*.rds
analysis/code/29          every figure and map, read only from the caches
analysis/code/30          every table, read only from the caches
analysis/output/          graphs/, maps/ (PDF and PNG), tables/ (LaTeX tabulars)
latex/                    paper.tex (submission, anonymized), appendix.tex (Online
                          Appendix), title_page.tex, paper_wp.tex (working paper);
                          the text is in latex/sections/; build.sh compiles all four
horario_verao/            project notes in Portuguese, legal texts; not needed to replicate
```

Each script describes in its header what it does and what it writes.

### License for code

To be set at deposit, in a `LICENSE.txt` at the root of the package.

## Instructions to replicators

1. Install R 4.4 and TeX Live, then run `Rscript config/00_setup.R` from the root of the
   package (open `DaylightSaving.Rproj`, or run from the root, so that `here::here()` resolves).
2. In `config/config.R`, set `DROPBOX_ROOT` to the folder that holds `build/`; in the
   package, that is `data/`.
3. Run the analysis and compile the paper:
   ```
   Rscript analysis/code/00_master_analysis.R
   latex/build.sh
   ```
4. To rebuild the data as well, first download the BR-DWGD rain grid named above into
   `build/weather/input/`, then run `Rscript config/00_master_build.R` before step 3.

### Details

- Run with the default draw counts. `DS_PERM` changes the 999 permutation draws of
  `06`, `14`, `16` and `26` at once and also turns on a permutation test in `09` that the
  paper does not use; `DS_BOOT` changes the 299 bootstrap draws of `05`. `DS_CORES` sets
  the number of worker processes only.
- `00_master_analysis.R 06 14` reruns single steps; `--from 15` reruns from a step on.
  Each script can also be run alone once its inputs exist.
- Numbers quoted in the text that no exhibit prints are traced, in a LaTeX comment beside
  each, to the cache that holds them (`latex/sections/*.tex`).

## List of tables and programs

The estimates come from the scripts in the last column; `29_figures.R` and `30_tables.R`
only read their caches and write the files. Figures are in `analysis/output/graphs/`
(maps in `analysis/output/maps/`) and tables in `analysis/output/tables/`.

| Exhibit | Program | Line | Output file | Estimated in |
|---|---|---|---|---|
| Figure 1 | `29_figures.R` | 442 | `maps/fig_map_brazil.pdf` | `build/01`, `12` |
| Figure 2 | `29_figures.R` | 143 | `fig_light.pdf` | `03` |
| Table 1 | `30_tables.R` | 75 | `tab_descriptives.tex` | `13` |
| Table 2 | `30_tables.R` | 107 | `tab_main.tex` | `01`, `06` |
| Figure 3 | `29_figures.R` | 165 | `fig_hours_from_sunset.pdf` | `01` |
| Figure 4 | `29_figures.R` | 184 | `fig_event_study.pdf` | `02` |
| Table 3 | `30_tables.R` | 265 | `tab_robustness.tex` | `04`, `05`, `08`, `09`, `18`, `20` |
| Table 4 | `30_tables.R` | 160 | `tab_dose.tex` | `23` |
| Table 5 | `30_tables.R` | 131 | `tab_pedestrians.tex` | `12`, `14` |
| Table 6 | `30_tables.R` | 184 | `tab_excess.tex` | `11`, `23` |
| Table 7 | `30_tables.R` | 396 | `tab_cost.tex` | `25` |
| Figure A1 | `29_figures.R` | 353 | `fig_record_integrity.pdf` | `22` |
| Figure B1 | `29_figures.R` | 312 | `fig_window_shift.pdf` | `19` |
| Figure B2 | `29_figures.R` | 336 | `fig_leave_out.pdf` | `20` |
| Table B1 | `30_tables.R` | 297 | `tab_sensitivity.tex` | `04`, `19`, `20`, `23` |
| Figure B3 | `29_figures.R` | 224 | `fig_window_legs.pdf` | `04` |
| Figure B4 | `29_figures.R` | 204 | `fig_within_day.pdf` | `02`, `09` |
| Table B2 | `30_tables.R` | 238 | `tab_within_group.tex` | `09`, `15` |
| Figure B5 | `29_figures.R` | 253 | `fig_honestdid.pdf` | `07` |
| Table B3 | `30_tables.R` | 349 | `tab_road_users.tex` | `21` |
| Table B4 | `30_tables.R` | 216 | `tab_traffic_volume.tex` | `15`, `16` |
| Table B5 | `30_tables.R` | 373 | `tab_street_lighting.tex` | `24` |
| Table B6 | `30_tables.R` | 471 | `tab_transitions.tex` | `28` |
| Figure B6 | `29_figures.R` | 290 | `fig_bahia.pdf` | `17` |
| Figure B7 | `29_figures.R` | 268 | `fig_assault.pdf` | `10` |
| Figure C1 | `29_figures.R` | 489 | `maps/fig_map_mexico.pdf` | `build/10`, `12` |
| Table C1 | `30_tables.R` | 431 | `tab_mexico.tex` | `26`, `27` |
| Figure C2 | `29_figures.R` | 374 | `fig_mexico_event_study.pdf` | `26` |

## References

Brasil. 2008. "Decreto nº 6.558, de 8 de setembro de 2008: Institui a hora de verão em parte do território nacional." *Diário Oficial da União*, Brasília.

Brasil. 2019. "Decreto nº 9.772, de 25 de abril de 2019: Encerra a hora de verão no território nacional." *Diário Oficial da União*, Brasília.

DNIT (Departamento Nacional de Infraestrutura de Transportes). 2025. "Plano Nacional de Contagem de Tráfego: Volume horário dos postos de contagem contínua, 2014–2019 and 2021–2025." servicos.dnit.gov.br/dadospnct (accessed October 2026).

GADM. 2022. "Database of Global Administrative Areas, Version 4.1: Mexico, Levels 1 and 2." gadm.org (accessed October 2026).

IBGE (Instituto Brasileiro de Geografia e Estatística). 2011. "Censo Demográfico 2010: Resultados do universo por setor censitário, entorno dos domicílios." Rio de Janeiro.

IBGE. 2020. "Malha Territorial: Unidades da Federação, 2020." Read with the R package geobr.

IBGE. 2023. "Censo Demográfico 2022: População residente (table 4709) and características urbanísticas do entorno dos domicílios (table 9839)." SIDRA, sidra.ibge.gov.br (accessed October 2026).

IBGE. 2026. "Índice Nacional de Preços ao Consumidor Amplo (IPCA), número-índice (table 1737)." SIDRA, sidra.ibge.gov.br (accessed October 2026).

INEGI (Instituto Nacional de Estadística y Geografía). 2026a. "Estadística de Accidentes de Tránsito Terrestre en Zonas Urbanas y Suburbanas (ATUS), datos abiertos 1997–2025." www.inegi.org.mx (accessed October 2026).

INEGI. 2026b. "Catálogo Único de Claves Geoestadísticas: Servicio web del Marco Geoestadístico." www.inegi.org.mx (accessed October 2026).

Ipea (Instituto de Pesquisa Econômica Aplicada) and PRF (Polícia Rodoviária Federal). 2015. "Acidentes de trânsito nas rodovias federais brasileiras: Caracterização, tendências e custos para a sociedade." Relatório de Pesquisa, Ipea, Brasília.

Meeus, Jean. 1998. *Astronomical Algorithms*. 2nd ed. Richmond, VA: Willmann-Bell.

Ministério da Saúde. 2025. "Sistema de Informações sobre Mortalidade (SIM): Microdados das declarações de óbito, 2008–2024." DATASUS, ftp.datasus.gov.br (accessed October 2026).

Natural Earth. n.d. "Admin 0 – Countries, 1:50m." naturalearthdata.com, read with the R package rnaturalearth.

NOAA Global Monitoring Division. n.d. "General Solar Position Calculations." gml.noaa.gov/grad/solcalc/solareqns.PDF (accessed October 2026).

Polícia Rodoviária Federal. 2025. "Dados abertos: Acidentes, agrupados por ocorrência, 2007–2025." www.gov.br/prf (accessed October 2026).

World Bank. 2026. "World Development Indicators: GNI per capita, PPP (current international \$) and PPP conversion factor, GDP." Series NY.GNP.PCAP.PP.CD and PA.NUS.PPP (accessed October 2026).

Xavier, Alexandre C., Bridget R. Scanlon, Carey W. King, and Aline I. Alves. 2022. "New Improved Brazilian Daily Weather Gridded Data (1961–2020)." *International Journal of Climatology* 42 (16): 8390–8404.
