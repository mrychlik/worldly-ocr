#!/bin/bash
# Use this script to convert the source book to page images in PPM format
mkdir -p Pages2
cd Pages2
pdftoppm -r 300 ../../../worldly-ocr/ChineseTextSamples/1866-chinese-poetry.pdf page
