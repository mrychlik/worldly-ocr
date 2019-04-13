#!/bin/bash
# Use this script to convert the source book to page images in PNG format
cd Pages
pdftopng -r 400 ../../Data/06061317.cn.pdf 06061317.cn
