#!/bin/sh

export TESSDATA_PREFIX=/usr/local/share/tessdata


# This will crash Tesseract with --oem 2 (i.e. LSTM engine)
/usr/local/bin/tesseract --oem 1 -l chi_tra_vert Pages/page-06.ppm base


