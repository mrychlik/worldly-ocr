# Harvesting characters from a good quality printed book

The master strip is my_script.m

## Sample training

![Training](images/SampleTraining.png)

## Use of Tesseract

We used Tesseract to transcribe individual Chinese characters to
Unicode.  Wee demonstrated by training is that we can train a system
to **simulate Tesseract behavior** (errors and all).

## The image of the weights

We ran learning in script2k.m, on a subset of 2000 Chinese characters
The training of the neural network produces a set of weights ***W***,
which is a 2104-by-8119 matrix:

![Training](images/LogAbsOfBestWeights.png)

Every row of the weight matrix (i.e. of the image above)
is an image. Making it into a frame of a movie results
in this video:

[![The "Catscan" Video](http://img.youtube.com/vi/tEyRGVuEgh4/0.jpg)](http://www.youtube.com/watch?v=tEyRGVuEgh4)

## Research Problem
Classify characters using unsupervised learning