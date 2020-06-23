#!/bin/bash
# Use tesseract to OCR the images in Ligatures.
# The output is in OutputAsWord
#
# The meaning of the parameter '--psm' to Tesseract
#
#  0    Orientation and script detection (OSD) only.
#  1    Automatic page segmentation with OSD.
#  2    Automatic page segmentation, but no OSD, or OCR. (not implemented)
#  3    Fully automatic page segmentation, but no OSD. (Default)
#  4    Assume a single column of text of variable sizes.
#  5    Assume a single uniform block of vertically aligned text.
#  6    Assume a single uniform block of text.
#  7    Treat the image as a single text line.
#  8    Treat the image as a single word.
#  9    Treat the image as a single word in a circle.
# 10    Treat the image as a single character.
# 11    Sparse text. Find as much text as possible in no particular order.
# 12    Sparse text with OSD.
# 13    Raw line. Treat the image as a single text line,
#       bypassing hacks that are Tesseract-specific.

DATADIR='BlackOnWhiteChars'
OUT='OutputsAsUTF8'
#LANG='chi_tra_vert'
LANG='chi_tra'
DPI=70
PSM=10	
OEM=1


mkdir -p $OUT
rm $OUT/char*.txt
for f in $DATADIR/*
do
    tesseract --oem $OEM --dpi $DPI -l $LANG --psm $PSM $f ${f%%.pbm}
    mv ${f%%.pbm}.txt $OUT
done
