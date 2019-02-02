%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This script preloads/computes the lines of text
%%%
%%% This file is a preamble to other files, which perform real processing
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Where to find pages of scanned text
imagedir=fullfile('.','images');

imagefile='Img_0322.jpg');
imagefile='02348.jpg';
imagefile='02351.jpg';


file=fullfile(imagedir,imagefile);



%% Build a cache of objects in the image
% Strings identifying page numbers in image files
% Where to save objects
savefile=fullfile('.','Cache','chi_sim_objects.mat');
if exist(savefile,'file') 
    load(savefile)
else 
    objects=[];
    I=imread(file);                         % Note: the image is BW
    BW=im2bw(I,.7);
    BW=~BW;
    lines=chi_bounding_boxes(BW,...
                             'Display','off',...
                             'DiacriticalMarks','on',...
                             'Method','kmeans');
    save(savefile,'lines')
end

chi_visualize_text(lines);