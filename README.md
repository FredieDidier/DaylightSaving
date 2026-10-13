# DaylightSaving

The end of daylight saving time in Brazil (Decree 9,772 of 25 April 2019) and
its effect on road deaths, with a replication on Mexico's abolition of 2022.

**Author:** Fredie Didier. First draft of the paper in `latex/` (target: AEJ: Economic Policy).

## Layout

```
config/config.R           the only file to edit (set DROPBOX_ROOT)
config/00_master_build.R  runs build/01-12 in order
build/manual/             legal DST calendar, typed from the decrees (versioned)
build/01-12               treatment calendar, then one step per data source
analysis/code/            00_master_analysis.R runs 01-29: 01-27 estimate and
                          cache audit/*.rds, 28 draws the figures, 29 the tables
analysis/output/          committed outputs: graphs/ (figures, .pdf and .png),
                          tables/ (.tex), maps/ (Brazil and Mexico, .pdf and .png)
latex/                    paper.tex (AEJ: Economic Policy submission, anonymized),
                          appendix.tex (Online Appendix), title_page.tex,
                          paper_wp.tex (working paper); the text lives in
                          latex/sections/ and is shared by all of them
horario_verao/            project notes (Portuguese), legal texts, skills
```

Data live outside the repository, under `DROPBOX_ROOT`. Every input the
project reads is in that one folder or is downloaded into it by a build script;
nothing is read from another project's folder.

| Source | Script | How it arrives |
|---|---|---|
| PRF federal-highway crashes | `02_download_prf.R`, `03_clean_prf.R` | PRF open-data downloads |
| Municipal seats and time zones | `04_municipal_geo.R` | `geobr`; zone rule written in the script |
| SIM deaths | `05_download_sim.R` | DATASUS FTP |
| PNCT traffic counts | `06_download_pnct.R`, `07_clean_pnct.R` | DNIT PNCT API |
| Xavier BR-DWGD rain | `08_xavier_rain.R` | **manual**: raw NetCDF kept in `build/weather/input/` |
| Census street lighting 2022 / 2010 | `09_census_lighting.R` | SIDRA API / `censobr` (columns kept in `build/census/input/`) |
| Mexico municipalities | `10_mexico_geo.R` | INEGI geo API |
| Mexico road crashes (ATUS) | `11_mexico_atus.R` | INEGI open data (raw zip in `build/mexico/input/`) |
| Boundaries for the maps | `12_map_boundaries.R` | `geobr` (IBGE, Brazil); GADM 4.1 via `geodata` (Mexico) |

## Requirements

- R 4.4 or later, with `data.table`, `arrow`, `fixest`, `fwildclusterboot`,
  `dqrng`, `HonestDiD`, `ggplot2`, `patchwork`, `ragg`, `sf`, `terra`,
  `geobr`, `geodata`, `rnaturalearth` (with `rnaturalearthdata`), `censobr`,
  `read.dbc`, `RCurl`, `curl`, `jsonlite`, `dplyr` and `here`.
- A TeX distribution with `pdflatex` and `bibtex` (TeX Live 2024 was used). The
  AEA template (`AEA.cls`, `aea.bst`) is in `latex/`.

## Reproducing

Open `DaylightSaving.Rproj` (so that `here::here()` resolves), set
`DROPBOX_ROOT` in `config/config.R`, then:

```
Rscript config/00_master_build.R
Rscript analysis/code/00_master_analysis.R
latex/build.sh
```

The first line builds the data, the second estimates everything and writes
the figures, maps and tables (`28_figures.R`, `29_tables.R`), and the third
compiles the paper, the Online Appendix, the title page and the working
paper. The compiled PDFs in `latex/` are not committed.

The Dropbox folder already holds every build output, so the analysis can run
on its own. `build/01_dst_calendar.R` checks the 2008–2018 dates against the
rule in Decree 6,558/2008, writes `calendar/output/dst_uf_season.parquet` and
`dst_uf_day.parquet` under `DROPBOX_ROOT/build/`, and regenerates
`horario_verao/TABELA_ESTADOS.md`.

## Sources

- DST decrees 1985–2019 and time-zone laws 11,662/2008 and 12,876/2013:
  <https://www.planalto.gov.br> (texts kept in `horario_verao/fontes_legais/`).
- Cross-reference: IANA tz database, `southamerica` file.
