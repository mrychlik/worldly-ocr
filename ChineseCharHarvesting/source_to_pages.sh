#!/bin/bash
# Use this script to convert the source book to page images in PPM format
cd Pages
pdftoppm -r 300 ../../worldly-ocr/Data/jinshijishi02chen.pdf page
