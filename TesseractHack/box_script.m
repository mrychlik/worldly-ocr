[I,cmap]=imread('BoxFileExample/39097174-8ee9c5d4-4676-11e8-9023-a9657006eabc.png');
[objects,lines]=bounding_boxes(~I);

fh = fopen('box_file.txt','w');

for j=1:length(objects)
    b = objects(j).BoundingBox;
    x=floor(b(1))); y=floor(b(2)); w=ceil(b(3)); h=ceil(b(4));
    fprintf(fh, '%c %d %d %d %d 0\n', x, y, x+w, y+h);
end

fclose(fh);