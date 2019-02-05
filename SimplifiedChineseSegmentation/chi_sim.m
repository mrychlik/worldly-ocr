%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This script preloads/computes the lines of text
%%%
%%% This file is a preamble to other files, which perform real processing
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Where to find pages of scanned text
imagedir=fullfile('.','images');
cachedir=fullfile('.','Cache');

% imagefile='Img_0322.jpg';
% imagefile='02348.jpg';
imagefile='02351.jpg';

threshold = 0.7;

filepath=fullfile(imagedir,imagefile);



%% Build a cache of objects in the image
% Strings identifying page numbers in image files
% Where to save objects
savefile=fullfile(cachedir,[imagefile,'.mat']);
if exist(savefile,'file') 
    load(savefile)
else 
    objects=[];
    I=imread(filepath);                 % Note: the image is BW
    BW=im2bw(I,threshold);
    BW=~BW;
    lines=chi_bounding_boxes(BW,...
                             'Display','on',...
                             'DiacriticalMarks','on',...
                             'Method','lloyds');
    save(savefile,'lines')
end

chi_visualize_text(lines);