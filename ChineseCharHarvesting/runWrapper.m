[I,cmap] = imread('Pages/page-06.ppm');
% Must transpose the image to work? Why.
J = uint8(I');
out = tessWrapper(J);
disp(out);