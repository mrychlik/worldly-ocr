[I,cmap]=imread('BoxFileExample/39097174-8ee9c5d4-4676-11e8-9023-a9657006eabc.png');
[ph,pw] = size(I);

savefile=fullfile('Cache','objects.mat');

if exist(savefile,'file') == 2
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end

fh = fopen('box_file.txt','w');

for l = 1:length(lines)
    for j=1:length(lines{l})
        obj = objects(lines{l}(j));
        b = obj.BoundingBox;
        x=floor(b(1)); y=floor(b(2)); w=ceil(b(3)); h=ceil(b(4));
        fprintf(fh, '%c %d %d %d %d %d\n', 'X', x, ph-(y+h), x+w, ph - y, l-1);
    end
    % Mark the end of the line
    fprintf(fh, '\t%d %d %d %d %d\n', x+w, ph-(y+h), x+w, ph-y, l-1);
end

fclose(fh);