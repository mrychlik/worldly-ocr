#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=~/Downloads/worldly-ocr-e190765e56f3.json

curl -X POST \
     -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
     -H "Content-Type: application/json; charset=utf-8" \
     --data "{
  'q': 'Hello world',
  'q': 'My name is Jeff',
  'target': 'de'
}" "https://translation.googleapis.com/language/translate/v2"
