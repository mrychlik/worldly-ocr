savefile=fullfile('Cache','objects.mat');

if exist(savefile,'file') == 2
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end


for j=1:length(objects)
    objects(j).grayscaleimage = objects(j).bwimage .* 255;
    objects(j).char = ' ';
end

label_objects(objects);