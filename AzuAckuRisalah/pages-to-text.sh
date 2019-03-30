#!/bin/bash
# Use this script to covert images in folder ./Pages to text in ./Text
TESSERACT=/usr/local/bin/tesseract

function do_book() {
    lang=$1
    for f in Pages/*
    do
	echo ${f##Pages/}
	g=${f##Pages/}
	h=${g%%.ppm}
	$TESSERACT --oem 1 --psm 3 -l $lang $f Text/${h}_lang
    done
}


do_book pus
