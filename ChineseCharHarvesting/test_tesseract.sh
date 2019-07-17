#!/bin/sh
# This will crash Tesseract with --oem 2 (i.e. LSTM engine)
tesseract --oem 2 -l chi_tra_vert Pages/page-06.ppm base
#tesseract --oem 1 -l chi_tra_vert Pages/page-06.ppm base
