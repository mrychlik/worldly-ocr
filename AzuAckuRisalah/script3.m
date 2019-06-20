%% Synopsis: This script implements a rudimentary OCR pipeline and consists of
%% these steps:
%%
%%    1. Binarization
%%    2. Breaking up image into lines
%%    3. Postprocessing to identify and attach diacriticals
%%    4. Invoking Tesseract to perform OCR
%%

%% Choose the image to be processed. The processing includes:

% Address of the folder the image is located
dirpath=fullfile('Pages');
% Name of the image
% imgname='page-06.ppm';
% imgname='page-07.ppm';
% imgname='page-08.ppm';
% imgname='page-09.ppm';
% imgname='page-10.ppm';
% imgname='page-11.ppm';
% imgname='page-12.ppm';
% imgname='page-13.ppm';
imgname='page-14.ppm';
% imgname='page-15.ppm';
% imgname='page-16.ppm';

%% reading the figure according to the address and defining the lines
imgfile=fullfile(dirpath,imgname);
I=imread(imgfile);
imshow(I);


%BW=~im2bw(I,.2);

%% Binarize the image

% method=1;                               % Same as threshold=.2
method = 2;
BW=BWThreshold(I,method);

imshow(BW);

%% Break up the image into lines
pause(1);
%BW=~im2bw(I,.2); 
BW=BWThreshold(I,1);

obj = LineBreaker(BW);

obj.show_labels();
pause(3);
obj.plot_lines();
pause(2);


%%
% Short lines could be diacriticals
obj.show_short_lines(.2);
drawnow;

% Set parameter to absorb diacriticals
obj.SigmaFactor=1;                      % To be experimentally determined
obj=merge_short_lines(obj);

% After merging diacriticals should be in their rightful places
obj.show_short_lines;


obj.play_lines(3);

for label=1:max(obj.LabeledLines)
    imshow(obj.LabeledLines==label); 
    pause(1); 
end