[I,cmap]=imread('BoxFileExample/39097174-8ee9c5d4-4676-11e8-9023-a9657006eabc.png');
[objects,lines]=bounding_boxes(~I);

for j=1:length(objects)
    imagesc(objects(j).bwimage), drawnow, pause(.1);
end