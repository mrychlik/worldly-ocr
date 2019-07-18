% Runs MEX wrapper around Tesseract 4 which computes the confidence
% of individual characters.
%
% The main effort is to understand how ROI are translated
% to Tesseract API rectangle.
%
% Also, we need to apply fliplr to the image, so that
% the Chinese characters are oriented propertly
% for chi_tra_vert language.
%

mfilename;

[I0,cmap] = imread('Pages/page-06.ppm');
I = rgb2gray(I0);
J = uint8(fliplr(I));
% ROI = [0,0,1000,100; 300,300,200,200];
% ROI = [1,1,400,100; 1, 500,400,100];

% A portion of the file PBoxes/page-06.txt which contains
% previously computed boxes of characters in the format y1,x1,y2,x2
boxes = [ 731 206 799 284
          808 320 875 397
          1036 321 1106 398
          1263 321 1332 400
          885 322 953 395
          1491 322 1561 401
          1648 322 1712 398
          1723 322 1792 401
          1800 322 1868 400 
          730 323 800 395
          961 323 1028 398
          1111 323 1180 401
          1339 323 1408 399
          1877 323 1943 400
          2331 323 2399 401
          1190 324 1256 392
          1417 324 1484 401
          2028 324 2094 399
          1567 325 1638 400
          2106 325 2174 400
          2258 325 2325 401
          2408 325 2479 402
          1950 326 2020 398
          2183 329 2250 401
          732 434 797 512
        ];

% Let us see what is in the original boxes

y1 = boxes(:,1); x1 = boxes(:,2); y2 = boxes(:,3); x2 = boxes(:, 4);

if false
    M=size(boxes,1);
    P=ceil(sqrt(M));
    for r = 1:M
        subplot(P,P,r);
        imagesc(I(y1(r):y2(r),x1(r):x2(r)));
        title(sprintf('Region #%d', r-1));
    end
end

[H,W] = size(I);
% Translate boxe to ROI

ROI = [ y1, W - x2, y2 - y1, x2 - x1];

out = tessWrapperWithConfidence(J,'chi_tra_vert','/usr/local/share/tessdata', ...
                                ROI);
disp(out);