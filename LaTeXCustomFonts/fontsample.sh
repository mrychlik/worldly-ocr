#!/bin/sh

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


pdftoppm -r 600 texput.pdf texput
#The command below does not crop properly
#convert -trim forpdflatex-*.ppm forpdflatex_trimmed.ppm

# This implements GIMP zealous crop programmatically
#./crop.sh forpdflatex-1.ppm forpdflatex.tiff

input=texput-1.ppm
output=texput.tiff
gimp -i -b "(crop-ppm \"$input\" \"$output\")" -b "(gimp-quit 0)"

