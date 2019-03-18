#!/bin/sh
lualatex forpdflatex.tex

pdftoppm -r 600 forpdflatex.pdf forpdflatex
#The command below does not crop properly
#convert -trim forpdflatex-*.ppm forpdflatex_trimmed.ppm

# This implements GIMP zealous crop programmatically
./crop.sh forpdflatex-1.ppm forpdflatex.tiff 

