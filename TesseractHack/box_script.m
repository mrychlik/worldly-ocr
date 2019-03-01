%
% File: box-script.m
% Author: Marek Rychlik
%
% This file builds a box file from MATLAB.
% The numbers appear consistent with automated Tesseract script up to 1 pixel.
%

%imagefile = fullfile('BoxFileExample','39097174-8ee9c5d4-4676-11e8-9023-a9657006eabc.png');


imagefile = fullfile('BoxFileExample','Paragraph.tif');
boxfile=fullfile('Cache','ParagraphBoxFile.txt');
savefile=fullfile('Cache','Paragraph.mat');

[I,cmap]=imread(imagefile);
I = im2bw(rgb2gray(I(:,:,1:3)));
[ph,pw] = size(I);

if exist(savefile,'file') == 2
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end

fh = fopen(boxfile,'w');

page=0;
for l = 1:length(lines)
    for j=1:length(lines{l})
        obj = objects(lines{l}(j));
        b = obj.BoundingBox;
        x=floor(b(1)); y=floor(b(2)); w=ceil(b(3)); h=ceil(b(4));
        fprintf(fh, '%c %d %d %d %d %d\n', 'X', x, ph-(y+h), x+w, ph - y, page);
    end
    % Mark the end of the line, except for the last line
    if l < length(lines)
        fprintf(fh, '\t%d %d %d %d %d\n', x+w, ph-y, x+w, ph-y, page);
    end
end

fclose(fh);