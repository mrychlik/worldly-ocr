#!/bin/bash

# Must be executed to install the GIMP script
#gimptool-2.0 --install-script crop-ppm.scm 

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

# set the filelist
input=$1
output=$2

gimp -i -b "(crop-ppm \"$input\" \"$output\")" -b "(gimp-quit 0)"


