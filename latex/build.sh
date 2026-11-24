#!/bin/sh
# Builds the AEJ: Economic Policy submission (paper, online appendix, title
# page, one disclosure statement per author) and the working paper. paper.tex and appendix.tex cite each other's
# labels through the xr package, so each is compiled after the other.
set -e
cd "$(dirname "$0")"
run() { pdflatex -interaction=nonstopmode -halt-on-error "$1.tex" > /dev/null; }
for f in appendix paper; do run $f; done
bibtex paper > /dev/null; bibtex appendix > /dev/null
for i in 1 2 3; do for f in appendix paper; do run $f; done; done
for f in title_page disclosure_didier disclosure_monasterio; do run $f; done
run paper_wp; bibtex paper_wp > /dev/null; run paper_wp; run paper_wp; run paper_wp
for f in paper appendix title_page disclosure_didier disclosure_monasterio paper_wp; do
  printf '%-12s %s pages\n' "$f" "$(pdfinfo $f.pdf | awk '/^Pages/ {print $2}')"
done
grep -a -h -E "Overfull|undefined|multiply defined|Rerun" paper.log appendix.log paper_wp.log | sort -u || true
