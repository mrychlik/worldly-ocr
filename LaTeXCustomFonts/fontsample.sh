#!/bin/sh
if [ $# -le 0 ]; then
    echo
    echo "Usage: $(basename $0) input.[ppm|pdf|...] output.ppm"
    echo
    echo "  This script uses gimp to autocrop PPM files and"
    echo "  save them to PPM format.  You must have"
    echo "  crop.scm installed in your gimp "
    echo "  scripts directory."
    echo
    exit 1
fi


#lualatex forpdflatex.tex
lualatex <<EOF
\documentclass{article}
% This is for LuaTeX or XeTeX
\usepackage{fontspec}
%\pdfmapfile{+myfont.map}
\setmainfont{[Lunafreya.ttf]}
\begin{document}
% Contains all letters of the English alphabet
\begin{LARGE}
The quick brown fox jumps over the lazy dog
\end{LARGE}
\end{document}
EOF


pdftoppm -r 600 forpdflatex.pdf forpdflatex
#The command below does not crop properly
#convert -trim forpdflatex-*.ppm forpdflatex_trimmed.ppm

# This implements GIMP zealous crop programmatically
#./crop.sh forpdflatex-1.ppm forpdflatex.tiff

input=forpdflatex-1.ppm
output=forpdflatex.tiff
gimp -i -b "(crop-ppm \"$input\" \"$output\")" -b "(gimp-quit 0)"

