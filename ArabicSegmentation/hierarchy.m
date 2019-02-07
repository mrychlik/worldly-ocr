% Where to put objects found in pages
file=fullfile('.','images', 'sinat-074.png');
% Where to find pages of scanned text
imagedir=fullfile('.','images');


%% Build a cache of objects in the image
% Strings identifying page numbers in image files
% Where to save objects
savefile=fullfile('.','Cache','ara_sinat_objects.mat');
if exist(savefile,'file') 
    load(savefile)
else
    error('Please run ''ara'' to create objects');
end


len = length(objects)

D = zeros(len,len);
for i = 1:(len-1)
    for j=(i+1):len
        D(i,j) = dist(objects(i),objects(j));
    end
end




