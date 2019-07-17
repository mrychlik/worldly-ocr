[I,cmap] = imread('images/phototest.tif');
% Must transpose the image to work? Why.
J = uint8(I');
out = tessWrapper(J);
disp(out);