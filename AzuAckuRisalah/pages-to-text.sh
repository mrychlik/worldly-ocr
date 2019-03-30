#!/bin/bash

TESSERACT=/usr/local/bin/tesseract

for f in Pages/*
do
    g=${f##Pages/}
    h=${g%%.ppm}
    $TESSERACT -l fas $f Text/${h}_fas
done
