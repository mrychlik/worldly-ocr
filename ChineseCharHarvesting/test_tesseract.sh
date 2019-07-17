#!/bin/sh
# This will crash Tesseract with --oem 2 (i.e. LSTM engine)
export TESSDATA_PREFIX=/usr/local/share

/usr/local/bin/tesseract --oem 1 -l chi_tra Pages/page-06.ppm base
#tesseract --oem 1 -l chi_tra_vert Pages/page-06.ppm base
