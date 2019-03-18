#!/bin/sh
lualatex forpdflatex.tex
pdftopng -r 600 forpdflatex.pdf forpdflatex.png
convert -quality 1 -trim forpdflatex.png forpdflatex_trimmed.png
