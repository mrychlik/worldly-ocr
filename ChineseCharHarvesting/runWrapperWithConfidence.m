[I0,cmap] = imread('Pages/page-06.ppm');
I = rgb2gray(I0);
J = uint8(fliplr(I));
out = tessWrapperWithConfidence(J,'chi_tra_vert','/usr/local/share/tessdata');
disp(out);