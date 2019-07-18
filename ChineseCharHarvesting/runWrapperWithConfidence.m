[I0,cmap] = imread('Pages/page-06.ppm');
I = rgb2gray(I0);
J = uint8(fliplr(I));
ROI = [0,0,1000,100; 300,300,200,200];
out = tessWrapperWithConfidence(J,'chi_tra_vert','/usr/local/share/tessdata', ...
                                ROI)
disp(out);