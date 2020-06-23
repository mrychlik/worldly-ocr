% This runs a MEX wrapper round Tesseract 3 on
% the test image

[I,cmap]=imread('images/phototest.tif');
% Must transpose the image to work? Why.
J=uint8(I');
tessWrapper3(J)