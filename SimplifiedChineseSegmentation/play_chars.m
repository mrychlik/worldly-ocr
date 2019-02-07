%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This script preloads/computes the lines of text
%%%
%%% This file is a preamble to other files, which perform real processing
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Where to find pages of scanned text
imagedir=fullfile('.','images');

% imagefile='Img_0322.jpg';
% imagefile='02348.jpg';
imagefile='02351.jpg';

pading = [10, 10];

filepath=fullfile(imagedir,imagefile);



%% Build a cache of objects in the image
% Strings identifying page numbers in image files
% Where to save objects
objects=[];
I=imread(filepath);                 % Note: the image is BW
BW=im2bw(I,.7);
BW=~BW;
conn=4;
[L,NUM] = bwlabel(BW,conn);
disp(sprintf('Found %d objects',NUM));
for n=0:NUM
    ob = L==n;
    ob_cropped = imautocrop(ob);
    ob_cropped_and_paded = padarray(ob_cropped, pading, 0);
    image(ob_cropped_and_paded.*255);
    drawnow;
    pause(.1);
end

