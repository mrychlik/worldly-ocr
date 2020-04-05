#!/bin/bash
# Use this script to convert the source book to page images in PPM format
cd Pages
pdftoppm -r 300 ../Source/azu_acku_risalah_ds371_2_zay48_1990_w.pdf page
