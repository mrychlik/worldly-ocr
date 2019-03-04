% File: fourier_clustering_script.m
% Author: Marek Rychlik (rychlik@email.arizona.edu)
% Date: 3-3-2019 3:33:14 PM
%
% In this script we implement an unsupervised learning strategy for
% labeling characters in a file, followed by a supervised strategy
% (manual labeling of cluster representatives).

% In the final step, we label all characters in the file, possibly
% correcting mistakes from the first two steps.

% Load a file previously created by box_script.m
savefile=fullfile('Cache','objects.mat');
%savefile=fullfile('Cache','Paragraph.mat');

if exist(savefile,'file') == 2
    fprintf('Loading savefile %s', savefile);
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end

is_labeled = isfield(objects,'char');

fprintf('Determining maximum object size...')
max_h = 0;
max_w = 0;
for j=1:length(objects)
    [h,w] = size(objects(j).bwimage);
    max_h = max(max_h, h);
    max_w = max(max_w, w);
end
fprintf('Max. height: %g, max. width: %g\n', max_h, max_w);

wb = waitbar(0, 'Cropping/centering objects and converting to grayscale...');
num_objects = length(objects);
for j=1:num_objects;
    waitbar(j/num_objects, wb);
    J = zeros([max_h,max_w],'uint8');
    BW = objects(j).bwimage;
    [h,w] = size(BW);
    x = round((max_w - w)/2);
    y = round((max_h - h)/2);
    J( (y+1):(y+h), (x+1):(x+w) ) = BW .* 255;
    objects(j).grayscaleimage = J;
    if ~is_labeled
        objects(j).char = '';
    end
end
close(wb);


[cluster_idx, num_clusters, cluster_reps] = fourier_clustering(objects,...
                                                  'Display','on',...
                                                  'Threshold', .85);

% Label cluster representatives
reps = objects(cluster_reps);
[reps,reps_changed] = label_objects(reps);

if reps_changed
    fprintf('Cluster reps were edited.\n');
end

% Assign same labels to equivalent objects
changed = false;
for j=1:num_clusters
    for k=find(cluster_idx==j)
        if ~strcmp(objects(k).char, reps(j).char)
            objects(k).char = reps(j).char;
            changed = true;
        end
    end
end
if changed
    fprintf('Some labels were changed.\n');
end

fprintf('Post-editing all labels...\n');
% Relabel all objects
[objects,changed_after] = label_objects(objects);

if changed_after
    fprintf('Some labels changed during post-editing.\n');
end


if changed || changed_after
    fprintf('Some object labels changed, saving new objects.\n');
    save(savefile,'objects','lines');
else
    fprintf('No labels changed, savefile unchanged.\n');
end