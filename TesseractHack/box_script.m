[I,cmap]=imread('BoxFileExample/39097174-8ee9c5d4-4676-11e8-9023-a9657006eabc.png');
[objects,lines]=bounding_boxes(~I);

%for j=1:length(objects)
for j=1
    %imagesc(objects(j).bwimage), drawnow, pause(.1);
    b = objects(j).BoundingBox;
    x=b(1); y=b(2); w=b(3); h=b(4);
end