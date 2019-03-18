#!/bin/sh
lualatex forpdflatex.tex
pdftoppm -r 600 forpdflatex.pdf forpdflatex.ppm
convert -trim forpdflatex.ppm forpdflatex_trimmed.ppm
