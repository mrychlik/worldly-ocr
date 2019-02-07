function objects=im2objects(BW)
%% Find connected components and extract region properties
stats=regionprops(BW,'BoundingBox','PixelList','Centroid',...
                  'FilledArea','ConvexArea','Area','PixelList','EulerNumber');

%% Extract images of individual objects
num_objects=numel(stats);
h=waitbar(0,'Extracting object info...');
for ob=1:num_objects
    waitbar(ob/num_objects,h);
    mask=zeros(size(BW),'uint8');
    pixellist=stats(ob).PixelList;
    % Crop image to bounding box of object
    mask(sub2ind(size(mask),pixellist(:,2), pixellist(:,1))) = 1;
    % Add some components to objects
    s=stats(ob);
    r=s.BoundingBox;
    objects(ob).BoundingBox=r;
    objects(ob).width=r(3);
    objects(ob).height=r(4);
    objects(ob).Centroid=s.Centroid;
    objects(ob).FilledArea=s.FilledArea;
    objects(ob).PixelList=s.PixelList;
    objects(ob).ConvexArea=s.ConvexArea;
    objects(ob).EulerNumber=s.EulerNumber;
    objects(ob).bwimage=imcrop(and(BW,mask),r);
end;
close(h);
