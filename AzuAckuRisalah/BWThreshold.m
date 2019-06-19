function [BW] = BWThreshold(I,Type,Thres)
% BWTHRESHOLD changes a color image to monochrome.
%  [BW] = BWTHRESHOLD(I,TYPE,Thres) changes a color image I to monochrome,
%  according to an integer TYPE grayscale first, then
%  using different methods based on Type, it changes the figure I to
%  grayscale and then to black and white.
%  Thres is defining the the threshold value; it is optional and the
%  default is 0.2
if  nargin < 3
    Thres=0.2;
end
Igray=rgb2gray(I);
 switch Type
    case 1 %Threshold is fixed at 0.2
        T=Thres;
    case 2 %Threshold is global using Otsu Method
        T=('global');
        if  nargin == 3
            warning("Thres parameter is not being used in Otsu Method!")
        end
    case 3 %Adaptive Filter using Mean Method
        T=adaptthresh(Igray,Thres,'ForegroundPolarity','dark','Statistic','mean');
    case 4 %Adaptive Filter using Gaussian Method
        T=adaptthresh(Igray,Thres,'ForegroundPolarity','dark','Statistic','gaussian');
    case 5 %Adaptive Filter using Median Method
        warning("Using Mean Method might be very time comsuming!")
        T=adaptthresh(Igray,Thres,'ForegroundPolarity','dark','Statistic','median');
end
BW=~imbinarize(Igray,T);
end

