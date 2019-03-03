%savefile=fullfile('Cache','objects.mat');
savefile=fullfile('Cache','Paragraph.mat');

if exist(savefile,'file') == 2
    fprintf('Loading savefile %s', savefile);
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end

[class_idx, class_num, class_reps] = fourier_clustering(objects)

% Label class representatives
reps = objects(find(class_reps));
reps = label_objects(reps);