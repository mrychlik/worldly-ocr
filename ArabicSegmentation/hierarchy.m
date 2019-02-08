% Where to put objects found in pages
file=fullfile('.','images', 'sinat-074.png');
% Where to find pages of scanned text
imagedir=fullfile('.','images');


%% Load objects from cache
% Strings identifying page numbers in image files
% Where to save objects
savefile=fullfile('.','Cache','ara_sinat_objects.mat');
if exist(savefile,'file') 
    load(savefile)
else
    error('Please run ''ara'' to create objects');
end


len = length(objects);

%% Compute mutual distances of objects
D = zeros(len,len);
parfor i = 1:(len-1)
    D(i,:) = arrayfun(@(ob)dist(objects(i),ob), objects);
    disp(i);
end


%% Do some form of hierarchical clustering
Z = linkage(D);
T = cluster(Z,'Cutoff',1,'Depth',2);
%C = cophenet(Z, D);

dendrogram(Z);