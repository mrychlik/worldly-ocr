# Harvesting characters from a good quality printed book

The master strip is my_script.m

## Sample training

![Training](images/SampleTraining.png)

## Use of Tesseract

We used Tesseract to transcribe individual Chinese characters
to Unicode. However, the results are not good.
Therefore, the training results are not usable. What we
demonstrated by training is that we can train a system
to **simulate Tesseract behavior** (errors and all).

Clearly, we need a different way to get the "Ground Truth"

## Research Problem
Classify characters using unsupervised learning