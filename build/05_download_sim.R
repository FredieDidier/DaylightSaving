# =============================================================================
# 05_download_sim.R
#
# The project's own death-register build (SIM), 2008-2025, straight from the
# DATASUS FTP, so that the analysis no longer borrows WorldCupHealth files and
# the 2008/09 season enters the sample.
#
# Output   sim/output/sim_<year>.parquet under DROPBOX_ROOT, lean columns only.
#
# File layout (same rule as WorldCupHealth's 09_download_sim_lean.R): most
# years carry 27 state files DO<UF><YYYY>.dbc plus a national DOBR<YYYY>.dbc;
# some years carry only the national one. State files are used where they
# exist and the national file otherwise, so no death is counted twice.
# The most recent year sits in the PRELIM directory and is flagged
# preliminary = TRUE; analysis scripts drop it.
#
# Raw .dbc files go to ~/Library/Caches/DaylightSaving and are deleted once a
# year is written. Resumable: a year whose parquet exists is skipped.
#
# Usage   Rscript build/05_download_sim.R [year_lo] [year_hi]
# =============================================================================

source(here::here("config", "config.R"))
suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(curl)
  library(RCurl)
  library(read.dbc)
})

FTP_CONS   <- "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DORES/"
FTP_PRELIM <- "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/PRELIM/DORES/"
KEEP <- c("DTOBITO", "HORAOBITO", "CODMUNOCOR", "CODMUNRES", "LOCOCOR",
          "CAUSABAS", "CIRCOBITO", "IDADE", "SEXO")
RETRIES <- 4L

args <- commandArgs(trailingOnly = TRUE)
y_lo <- if (length(args) >= 1) as.integer(args[1]) else 2008L
y_hi <- if (length(args) >= 2) as.integer(args[2]) else 2025L

path_sim_out <- file.path(DROPBOX_ROOT, "build", "sim", "output")
raw_dir      <- file.path(Sys.getenv("HOME"), "Library", "Caches", "DaylightSaving", "sim_dbc")
dir.create(path_sim_out, recursive = TRUE, showWarnings = FALSE)
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

listing <- function(u) {
  for (a in seq_len(RETRIES)) {
    l <- tryCatch(RCurl::getURL(u, ftp.use.epsv = TRUE, dirlistonly = TRUE),
                  error = function(e) NULL)
    if (!is.null(l)) break
    Sys.sleep(5 * a)
  }
  if (is.null(l)) stop("FTP listing failed: ", u)
  f <- unlist(strsplit(l, "\r*\n"))
  f[grepl("^DO[A-Z]{2}[0-9]{4}[.]dbc$", f)]
}
cons <- listing(FTP_CONS)
prel <- tryCatch(listing(FTP_PRELIM), error = function(e) character(0))
message(sprintf("FTP: %d consolidated files, %d preliminary", length(cons), length(prel)))

for (yr in y_lo:y_hi) {
  out <- file.path(path_sim_out, sprintf("sim_%d.parquet", yr))
  if (file.exists(out)) { message(yr, ": already built"); next }

  in_cons <- any(grepl(sprintf("%d[.]dbc$", yr), cons))
  src  <- if (in_cons) FTP_CONS else FTP_PRELIM
  pool <- if (in_cons) cons else prel
  fy   <- pool[grepl(sprintf("%d[.]dbc$", yr), pool)]
  if (!length(fy)) { message(yr, ": not on the FTP"); next }
  st <- fy[!grepl("^DOBR", fy)]
  fy <- if (length(st)) st else fy

  urls  <- paste0(src, fy)
  dests <- file.path(raw_dir, fy)
  for (a in seq_len(RETRIES)) {
    todo <- !(file.exists(dests) & file.size(dests) > 0)
    if (!any(todo)) break
    tryCatch(curl::multi_download(urls[todo], dests[todo], resume = TRUE, progress = FALSE,
                                  timeout = 900, multiplex = FALSE, connecttimeout = 30),
             error = function(e) message("  download error: ", conditionMessage(e)))
    Sys.sleep(5 * a)
  }
  if (any(!(file.exists(dests) & file.size(dests) > 0)))
    stop(yr, ": files still missing after retries: ",
         paste(fy[!(file.exists(dests) & file.size(dests) > 0)], collapse = ", "))

  z <- rbindlist(lapply(dests, function(f) {
    d <- as.data.table(read.dbc::read.dbc(f, as.is = TRUE))
    kc <- intersect(KEEP, names(d))
    d <- d[, ..kc]
    d[, (kc) := lapply(.SD, as.character)]
    d
  }), use.names = TRUE, fill = TRUE)
  z[, `:=`(year_file = yr, preliminary = !in_cons, n_files = length(fy))]

  write_parquet(z, out, compression = "zstd")
  message(sprintf("%d: %s deaths from %d files%s", yr, format(nrow(z), big.mark = ","),
                  length(fy), if (!in_cons) " (PRELIMINARY)" else ""))
  unlink(dests)
}
