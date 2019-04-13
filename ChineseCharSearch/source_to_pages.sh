#!/bin/bash
# Use this script to convert the source book to page images in PPM format
cd Pages
pdftopng -r 300 ../../Data/06061317.cn.pdf 06061317.cn
