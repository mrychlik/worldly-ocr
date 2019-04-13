#!/bin/bash
# Use this script to convert the source book to page images in PPM format
cd Pages
pdftopng -r 300 ../../worldly-ocr/Data/06061317.cn.pdf page
