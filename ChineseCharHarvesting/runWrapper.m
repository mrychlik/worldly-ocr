[I0,cmap] = imread('Pages/page-06.ppm');
I = rgb2gray(I0);
% We tried 'chi_tra_vert', but it crashes. Therefore,
% we transposed the image, which allows us to use 'chi_tra'.
% Too bad...
J = uint8(I');
out = tessWrapper(J,'chi_tra');
disp(out);