%This script tries to decompose a page to its lines
% and use Matlab OCR to show the translation
%Furthermore, it draws some pics which are very useful 

clc;clear;close all
BigSizeThresh=10000; %The maximum number of pixels considered as a text
SmallSizeThresh=10;  %The manimum number of pixels considered as a text
BinzarazationType=2; %The type for binarization 
BinzarazationThresh=0.2; %The parameter for binarization
Vexpansion = 0.0; %in percent
Hexpansion = 0.2; %in percent
%%
%Reading the Image and Convert to Binarazid
colorImage = imread(fullfile('Pages','page-14.png'));
I=~BWThreshold(colorImage,BinzarazationType,BinzarazationThresh);
I = ~bwareaopen(I,BigSizeThresh);     %removing the big connected region
I = ~bwareaopen(I,SmallSizeThresh);        %removing the small connected regions
figure;
subplot(1,2,1);imshow(colorImage);title('original')
subplot(1,2,2);imshow(I);title('binarized')
%%
%Finding the Text and connected region
[mserConnComp] = bwconncomp(~I);
mserStats = regionprops(mserConnComp, 'BoundingBox', 'Extent', 'Image','Centroid','Orientation');
%%
% Get bounding boxes for all the regions
bboxes = vertcat(mserStats.BoundingBox);
% Convert [x y width height] to the [xmin ymin xmax ymax]
[xmin,ymin,xmax,ymax]=BoxConverter(bboxes(:,1),bboxes(:,2),bboxes(:,3),bboxes(:,4));
% Expand the bounding boxes by a small amount.
[xmin,ymin,xmax,ymax]=BoxExpand(xmin,ymin,xmax,ymax,Vexpansion,Hexpansion,I);
% Show the expanded bounding boxes
[expandedBBoxes(:,1),expandedBBoxes(:,2),expandedBBoxes(:,3),expandedBBoxes(:,4)]=InvBoxConverter(xmin,ymin,xmax,ymax);
IExpandedBBoxes = insertShape(colorImage,'Rectangle',expandedBBoxes,'LineWidth',3,'Color',{'green'});
figure
subplot(1,2,1);imshow(IExpandedBBoxes);axis on
title('Expanded Bounding Boxes Text')
%%
[bboxes]=OverLapFinder(expandedBBoxes,xmin,ymin,xmax,ymax);
bboxesIntiial=bboxes;

 for i=1:2
[xmin,ymin,xmax,ymax]=BoxConverter(bboxes(:,1),bboxes(:,2),bboxes(:,3),bboxes(:,4));
[xmin,ymin,xmax,ymax]=BoxExpand(xmin,ymin,xmax,ymax,Vexpansion,Hexpansion,I);
[bboxes]=OverLapFinder(bboxes,xmin,ymin,xmax,ymax);
 end

 for i=1:10
[xmin,ymin,xmax,ymax]=BoxConverter(bboxes(:,1),bboxes(:,2),bboxes(:,3),bboxes(:,4));
[xmin,ymin,xmax,ymax]=BoxExpand(xmin,ymin,xmax,ymax,0,0,I);
[bboxes]=OverLapFinder(bboxes,xmin,ymin,xmax,ymax);
 end

 
% Show the final text detection result.
%ITextRegion = insertShape(colorImage, 'Rectangle', bboxes,'LineWidth',4,'Color',{'green'});
str      = sprintf('Box = %f', xmin);
for ii=1:length(xmin)
    label_str{ii} = ['Xmin=',num2str(xmin(ii)*100,'%0.2f')];
end

ITextRegion = insertObjectAnnotation(colorImage, 'Rectangle', bboxes,label_str,'LineWidth',4,'Color',{'green'});
subplot(1,2,2);imshow(ITextRegion);axis on
title('Detected Text')

%%location figures
figure
%1
subplot(2,2,1);
x=bboxesIntiial(:,1)+bboxesIntiial(:,3);
y=bboxesIntiial(:,2)+bboxesIntiial(:,4)/2;
scatter(x,y);title("begginign and middle of each legature")
xlim([0 size(I,2)]);ylim([0 size(I,1)]);set(gca, 'YDir','reverse');grid on;daspect([1 1 1])
%2
subplot(2,2,2);
x=bboxes(:,1)+bboxes(:,3);
y=bboxes(:,2)+bboxes(:,4)/2;
scatter(x,y);title("begginign and middle of each line")
xlim([0 size(I,2)]);ylim([0 size(I,1)]);set(gca, 'YDir','reverse');grid on;daspect([1 1 1])
%3
subplot(2,2,3);
for i=1:size(bboxesIntiial,1)
    rectangle('Position',bboxesIntiial(i,:));hold on
end
title("surrounding box of each legature")
xlim([0 size(I,2)]);ylim([0 size(I,1)]);set(gca, 'YDir','reverse');grid on;daspect([1 1 1])
%4
subplot(2,2,4);
for i=1:size(bboxes,1)
    rectangle('Position',bboxes(i,:));hold on
end
title("surrounding box of each line")
xlim([0 size(I,2)]);ylim([0 size(I,1)]);set(gca, 'YDir','reverse');grid on;daspect([1 1 1])

%%Hist figures
figure
subplot(2,2,1);hist(bboxesIntiial(:,3));title("width of each word")
subplot(2,2,2);hist(bboxes(:,3))       ;title("width of each line")
subplot(2,2,3);hist(bboxesIntiial(:,4));title("hight of each word")
subplot(2,2,4);hist(bboxes(:,4))       ;title("hight of each line")


%line by line
results1 = ocr(I,bboxes,'TextLayout','Line','Language','Arabic');
[results1.Text]
%word by word
results2 = ocr(I,bboxesIntiial,'TextLayout','Line','Language','Arabic');
[results2.Text]
%the whole page
results3 = ocr(I,'TextLayout','Block','Language','Arabic');
[results3.Text]



function [xmin,ymin,xmax,ymax]=BoxConverter(xmin,ymin,width,height)
xmax = xmin + width - 1;
ymax = ymin + height- 1;
end

function [xmin,ymin,width,height]=InvBoxConverter(xmin,ymin,xmax,ymax)
width=xmax-xmin+1 ;
height=ymax-ymin+1;
end

function [xmin,ymin,xmax,ymax]=BoxExpand(xmin,ymin,xmax,ymax,Vexpansion,Hexpansion,Image)
XExpand=(xmax-xmin)*Hexpansion/2;
YExpand=(ymax-ymin)*Vexpansion/2;
xmin =  xmin-XExpand;
ymin =  ymin-YExpand;
xmax =  xmax+XExpand;
ymax =  ymax+YExpand;

% Clip the bounding boxes to be within the image bounds
xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(Image,2));
ymax = min(ymax, size(Image,1));
end


function [textBBoxes]=OverLapFinder(expandedBBoxes,xmin,ymin,xmax,ymax)
% Compute the overlap ratio
overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);
% Set the overlap ratio between a bounding box and itself to zero to simplify the graph representation.
n = size(overlapRatio,1); 
overlapRatio(1:n+1:n^2) = 0;
% Create the graph
g = graph(overlapRatio);
% Find the connected text regions within the graph
componentIndices = conncomp(g);
% Merge the boxes based on the minimum and maximum dimensions.
xmin = accumarray(componentIndices', xmin, [], @min);
ymin = accumarray(componentIndices', ymin, [], @min);
xmax = accumarray(componentIndices', xmax, [], @max);
ymax = accumarray(componentIndices', ymax, [], @max);
% Compose the merged bounding boxes using the [x y width height] format.
[textBBoxes(:,1),textBBoxes(:,2),textBBoxes(:,3),textBBoxes(:,4)]=InvBoxConverter(xmin,ymin,xmax,ymax);
end
