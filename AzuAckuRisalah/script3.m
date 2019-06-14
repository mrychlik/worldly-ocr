dirpath=fullfile('Pages');
%imgname='page-06.ppm';
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

imgfile=fullfile(dirpath,imgname)
I=imread(imgfile);
imshow(I);

%BW=~im2bw(I,.2);

method=1;                               % Same as threshold=.2
BW=BWThreshold(I,method);

obj = LineBreaker(BW);

obj.show_labels();
pause(3);
obj.plot_lines();
pause(2);


% Short lines could be diacriticals
obj.show_short_lines(.2);
drawnow;

% Set parameter to absorb diacriticals
obj.SigmaFactor=1;                      % To be experimentally determined

obj=merge_short_lines(obj);

% After merging diacriticals should be in their rightful places
obj.show_short_lines;


obj.play_lines(3);

