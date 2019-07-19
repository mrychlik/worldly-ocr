#!/bin/bash
# Use this script to convert the source book to page images in PPM format
mkdir -p Pages3
cd Pages3
pdftoppm -r 300 ../../../worldly-ocr/ChineseTextSamples/1826-履園叢話.pdf page
