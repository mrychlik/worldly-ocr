function [BW] = BWThreshold(I,Type)
% BWTHRESHOLD changes a color image to monochrome.
%  [BW] = BWTHRESHOLD(I,TYPE) changes a color image I to monochrome,
%  according to an integer TYPE grayscale first, then
%  using different methods based on Type, it changes the figure I to
%  grayscale and then to black and white.
    Igray=rgb2gray(I);
    switch Type
      case 1 %Threshold is fixed at 0.2
        T=0.2;
      case 2 %Threshold is global using Otsu method
        T=('global');
      case 3 %Adaptive Filter using Mean Method
        T=adaptthresh(Igray,0.2,'ForegroundPolarity','dark','Statistic','mean');
      case 4 %Adaptive Filter using Gaussian Method
        T=adaptthresh(Igray,0.2,'ForegroundPolarity','dark','Statistic','gaussian');dirpath=fullfile('Pages');
imgname='page-01.ppm';
%imgname='page-06.ppm';
% imgname='page-07.ppm';
% imgname='page-08.ppm';
% imgname='page-09.ppm';
% imgname='page-10.ppm';
% imgname='page-11.ppm';
% imgname='page-12.ppm';
% imgname='page-13.ppm';
% imgname='page-14.ppm';
% imgname='page-15.ppm';
% imgname='page-16.ppm';

imgfile=fullfile(dirpath,imgname)
I=imread(imgfile);
imshow(I);

%BW=~im2bw(I,.2);

method=2;                               % Same as threshold=.2
BW=BWThreshold(I,method);

imshow(BW);

      case 5 %Adaptive Filter using Median Method
             % warning(msg)
        T=adaptthresh(Igray,0.2,'ForegroundPolarity','dark','Statistic','median');
    end
    BW=~imbinarize(Igray,T);
end

