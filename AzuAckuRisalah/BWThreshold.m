function [BW] = BWThreshold(I,Type)
%% This is function to use change a color image to grayscale first,
%%  then using different methods based on Type, it changes the figure I to grayscale and then to Balck and White
    Igray=rgb2gray(I);
    switch Type
      case 1 %Threshold is fixed at 0.2
        T=0.2;
      case 2 %Threshold is global using Otsu method
        T=('global');
      case 3 %Adaptive Filter using Mean Method
        T=adaptthresh(Igray,0.2,'ForegroundPolarity','dark','Statistic','mean');
      case 4 %Adaptive Filter using Gaussian Method
        T=adaptthresh(Igray,0.2,'ForegroundPolarity','dark','Statistic','gaussian');
      case 5 %Adaptive Filter using Median Method
             % warning(msg)
        T=adaptthresh(Igray,0.2,'ForegroundPolarity','dark','Statistic','median');
    end
    BW=~imbinarize(Igray,T);
end

