# =============================================================================
# config.R
#
# Machine-specific settings and the constants every build and analysis script
# shares. It is the first file each of them sources.
#
# The ONLY line to edit when reproducing the project on another machine is
# DROPBOX_ROOT. Every repository path resolves through here::here().
#
# The project asks what happened to road deaths when Brazil abolished daylight
# saving time (Decree 9,772 of 25 April 2019). See
# horario_verao/CONTEXTO_PESQUISA.md.
#
# Microdata NEVER enter git. They live under DROPBOX_ROOT.
# =============================================================================

DROPBOX_ROOT <- "/Users/fredie/Library/CloudStorage/Dropbox/DaylightSaving"

# Test hook: DS_DROPBOX_ROOT redirects the whole data tree to a scratch folder,
# so a test never touches the real files.
if (nzchar(Sys.getenv("DS_DROPBOX_ROOT")))
  DROPBOX_ROOT <- Sys.getenv("DS_DROPBOX_ROOT")

# ── Build paths (Dropbox — data, never versioned) ───────────────────────────
# Convention: input/ keeps the raw file as delivered by the source; output/
# keeps the constructed object.
path_calendar_out <- file.path(DROPBOX_ROOT, "build", "calendar", "output")
path_sim_out      <- file.path(DROPBOX_ROOT, "build", "sim", "output")
path_audit        <- file.path(DROPBOX_ROOT, "build", "audit")

for (p in c(path_calendar_out, path_audit))
  dir.create(p, recursive = TRUE, showWarnings = FALSE)

# Xavier BR-DWGD v3.2.4 daily precipitation, 0.1 degree grid, 2001-2025, as
# downloaded by hand from the authors' site (no script can fetch it), kept in
# Dropbox as delivered. Read once by build/08_xavier_rain.R.
path_xavier_pr <- file.path(DROPBOX_ROOT, "build", "weather", "input",
                            "pr_20010101_20251231_BR-DWGD_UFES_UTEXAS_v_3.2.4.nc")

# ── Repository paths (GitHub — versioned) ───────────────────────────────────
# build/manual/ holds the hand-coded legal calendar. It is small, typed from
# the decrees themselves, and versioned on purpose: it is the source of truth
# for treatment timing.
path_manual <- here::here("build", "manual")
path_tables <- here::here("analysis", "output", "tables")
path_graphs <- here::here("analysis", "output", "graphs")
path_maps   <- here::here("analysis", "output", "maps")

# ── Constants ───────────────────────────────────────────────────────────────
# The 27 federative units, in IBGE code order.
UFS <- c("RO", "AC", "AM", "RR", "PA", "AP", "TO",
         "MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA",
         "MG", "ES", "RJ", "SP",
         "PR", "SC", "RS",
         "MS", "MT", "GO", "DF")

# The decree that ended DST. The 2019/20 season would have started on the
# first Sunday of November 2019 (Decree 9,242/2017 rule).
DST_ABOLITION_DATE   <- as.Date("2019-04-25")
FIRST_MISSING_SEASON <- "2019/20"
