#!/bin/bash

DATADIR='Ligatures'

for f in $DATADIR/*
do
    echo tesseract -l pus --psm 7 $f ${f%%.bmp}
done
