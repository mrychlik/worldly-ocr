% Create a sparse version of ligatures and save it
% to MAT-file. The result is 1/10 of the uncropped
% images, which have a lot of zeros. 
% Ouptuts:
%      cropped.mat - a file with variables cropped, w, h, nsamples
% where:
%      cropped     - a structure array with fields
%                    image - the image
%                    bbox  - the bounding box
%      w           - the original image width (400)
%      h           - the original image height (400)
%      nsamples    - number of ligatures (3999)

if ~exist('ligatures','var');
    load('ligatures.mat');
end
[h, w, nsamples] = size(ligatures);

for idx=1:nsamples
    sparse_ligatures(idx).image = sparse(I);
end

save('sparse.mat','sparse_ligatures','w','h','nsamples','-v7');