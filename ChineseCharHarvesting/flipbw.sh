#!/bin/bash

DATADIR='BWChars'
OUT='BlackOnWhiteChars'

mkdir -p $OUT

for f in $DATADIR/*
do
    convert $f -negate $OUT/$f
done
