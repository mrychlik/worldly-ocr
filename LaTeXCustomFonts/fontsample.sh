#!/bin/sh
lualatex forpdflatex.tex

pdftoppm -r 600 forpdflatex.pdf forpdflatex
./crop.sh forpdflatex-1.ppm forpdflatex.tiff 

