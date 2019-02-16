Evaluation of the quality of images in the ligature database
============================================================

The ligature database at a first glance appears to have low-quality BW
images.  It turns out that this is not the case. The images are
actually grayscale. 

The BW appearance is a result of the fact that the signal was
truncated at both low and high intensities. This could have been done
by the scanner hardware, during analog-to-digital conversion
(more likely). 

The truncation could have also been done by software during
postprocessing. This is immaterial. The take-away is that the gray
levels are quite high quality and this fact can be used to our
benefit.


Testing of DWT (discreate wavelete transform) on ligatures
==========================================================

For 400x400 images, there is a need to perform "dimension
reduction". Due to the nature of the data, I (MR) have not even tried
Fourier transform techniques, as I know it would fail.

The alternative is to use DWT. I tested several wavelet types and the
best amongst them appears to be 'db2' (Doubachies wavelet of order 2).
It appears to achieve the following goals:

	- It reduces data by a factor of 16
	- It preserves the features of the ligatures well

TODO: One would want to quantify my statement, bu using SNR or
similar measure of quality.



