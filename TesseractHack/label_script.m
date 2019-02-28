savefile=fullfile('Cache','objects.mat');

if exist(savefile,'file') == 2
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end



max_h = 0;
max_w = 0;

for j=1:length(objects)
    [h,w] = size(objects(j).bwimage);
    max_h = max(max_h, h);
    max_w = max(max_w, w);
end
    
    




for j=1:length(objects)
    objects(j).grayscaleimage = objects(j).bwimage .* 255;
    objects(j).char = ' ';
end

%label_objects(objects);