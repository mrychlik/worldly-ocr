#!/bin/sh
lualatex forpdflatex.tex
pdftoppm -r 600 forpdflatex.pdf forpdflatex.ppm
convert -quality 1 -trim forpdflatex.ppm forpdflatex_trimmed.ppm
