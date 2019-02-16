% Create a sparse version of ligatures and save it
% to MAT-file. The result is 1/10 of the uncropped
% images, which have a lot of zeros. 
% Ouptuts:
%      cropped.mat - a file with variables cropped, w, h, nsamples
% where:
%      sparse_ligatures - a structure array with fields
%                         image - the image
%                         bbox  - the bounding box
%      w                - the original image width (400)
%      h                - the original image height (400)
%      nsamples         - number of ligatures (3999)

if ~exist('ligatures','var');
    load('ligatures.mat');
end
[h, w, nsamples] = size(ligatures);

min_top = 1;
max_bottom = 400;

for idx=1:nsamples
    I = squeeze(ligatures(:,:,idx));
    [bottom, top] = vert_size(I);
    min_top = min(top, min_top);
    max_bottom = max(bottom, max_bottom);
    sparse_ligatures(idx).image = sparse(I);
end

for idx=1:nsamples
    sparse_ligatures(idx).image = sparse_ligatures(idx).image(max_bottom:min_top,:);
end



save('sparse.mat','sparse_ligatures','w','h','nsamples','min_top','max_bottom','-v7');
