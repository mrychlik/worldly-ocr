# Experiments in Integration of Tesseract with Google Cloud translation service

## Primary Source

The data for the experiment is a book in Persian [Azu Acku
Risala](./Source/azu_acku_risalah_ds371_2_zay48_1990_w.pdf).

## Processing

NOTE: The code in this folder runs under Linux, but can be easily
adopted for another OS.

The workflow implemented in this folder is:
- We split the book into individual pages in folder [Pages](./Pages).
- Every page is subjected to a custom page segmentation algorithm
implemented in MATLAB, which divides pages into lines of text.
- Every line of text is submitted to the Tesseract OCR engine.
- The resulting text is submitted to the Google Cloud translation service.
  This step requires that the user subscribed to Google Cloud and has
  a valid API key. This is ***not a free service*** after the trial period.


## The Language

The document language is Persian (Farsi). However, Tesseract was run
in both the Persian and Pashto mode. It should be noted that the two
languages are requested in two different ways on Tesseract command
line:

   - 'tesseract -l pus ...' for Pashto
   - 'tesseract -l fas ...' for Farsi
