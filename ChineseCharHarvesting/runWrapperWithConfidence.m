[I0,cmap] = imread('Pages/page-06.ppm');
I = rgb2gray(I0);
J = uint8(fliplr(I));
% ROI = [0,0,1000,100; 300,300,200,200];
ROI = [1,1,400,100; 1, 500,400,100];

for r = 1:size(ROI,1)
    x = ROI(r,1); y = ROI(r,2); w = ROI(r,3); h = ROI(r, 4);
    imagesc(J(y:(y+h-1),x:(x+w-1)));
    pause(4);
end

out = tessWrapperWithConfidence(J,'chi_tra_vert','/usr/local/share/tessdata', ...
                                ROI)
disp(out);