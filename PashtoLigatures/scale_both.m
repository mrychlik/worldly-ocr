function [J1,J2] = scale_both(I1,I2)
% Scale two images to the smallest equal size
[h1,w1] = size(I1);
[h2,w2] = size(I2);
h = max(h1,h2);
w = max(w1,w2);
J1 = padarray(I1,[h-h1,w-w1],255,'pre');
J2 = padarray(I2,[h-h2,w-w2],255,'pre');