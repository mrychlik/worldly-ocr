#!/bin/bash

DATADIR='BWChars'
OUT='BlackOnWhiteChars'

mkdir -p $OUT

for f in $DATADIR/*
do
    g=$(basename $f)
    convert $f -negate $OUT/$g
done
