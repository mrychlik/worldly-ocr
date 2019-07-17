[I0,cmap] = imread('Pages/page-06.ppm');
% Must transpose the image to work? Why.
I = rgb2gray(I0);
J = uint8(I');
out = tessWrapper(J);
disp(out);