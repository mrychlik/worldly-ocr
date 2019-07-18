[I0,cmap] = imread('Pages/page-06.ppm');
I = rgb2gray(I0);
J = uint8(fliplr(I));
% ROI = [0,0,1000,100; 300,300,200,200];
% ROI = [1,1,400,100; 1, 500,400,100];

boxes = [ 731 206 799 284
          808 320 875 397
          1036 321 1106 398
          1263 321 1332 400
          885 322 953 395
          1491 322 1561 401
          1648 322 1712 398
          1723 322 1792 401
          1800 322 1868 400 ];

% Let us see what is in the original boxes
for r = 1:size(boxes,1)
    y1 = boxes(r,1); x1 = boxes(r,2); y2 = boxes(r,3); x2 = boxes(r, 4);
    imagesc(I(y1:y2,x1:x2));
    pause(0.5);
end

% Translate boxe to ROI
y = boxes(:,1);
x = boxes(:,2);
h = boxes(:,3)-boxes(:,1);
w = boxes(:,4)-boxes(:,2);

ROI = [ x, y, w, h];

out = tessWrapperWithConfidence(J,'chi_tra_vert','/usr/local/share/tessdata', ...
                                ROI)
disp(out);