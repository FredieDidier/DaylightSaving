# DaylightSaving

The end of daylight saving time in Brazil (Decree 9,772 of 25 April 2019) and
its effects on traffic deaths, violence, health and the timing of births.

**Author:** Fredie Didier. Work in progress — no paper yet.

## Layout

```
config/config.R           the only file to edit (set DROPBOX_ROOT)
build/manual/             legal DST calendar, typed from the decrees (versioned)
build/01_dst_calendar.R   builds the UF x season and UF x day treatment panels
analysis/                 code and committed outputs (tables .tex, figures .pdf/.png)
latex/                    manuscript (later)
horario_verao/            project notes (Portuguese), legal texts, skills
```

Data live outside the repository, under `DROPBOX_ROOT`.

## Reproducing the treatment calendar

Open `DaylightSaving.Rproj` (so that `here::here()` resolves), set
`DROPBOX_ROOT` in `config/config.R`, then:

```
Rscript build/01_dst_calendar.R
```

It checks the 2008–2018 dates against the rule in Decree 6,558/2008, writes
`calendar/output/dst_uf_season.parquet` and `dst_uf_day.parquet` under
`DROPBOX_ROOT/build/`, and regenerates `horario_verao/TABELA_ESTADOS.md`.

## Sources

- DST decrees 1985–2019 and time-zone laws 11,662/2008 and 12,876/2013:
  <https://www.planalto.gov.br> (texts kept in `horario_verao/fontes_legais/`).
- Cross-reference: IANA tz database, `southamerica` file.
