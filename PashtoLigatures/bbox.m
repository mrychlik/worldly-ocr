function [BWCropped,BBox]=bbox(BW)
%BBOX Extract the bounding box of a BW image and crop the image.
%  [BWCROPPED,BBOX] = BBOX(BW) accepts a black-and-white image
%  BW and it returns a cropped image BWCROPPED and the bounding
%  box BBBOX.

% Create a mask
% Idiom: convert a pixel list to mask
[I,J]=find(BW);
% Crop image to bounding box of object
BBox=[min(J),min(I),range(J),range(I)];
BWCropped=imcrop(BW,BBox);
