%
% This script scans through the pages of a book in Chinese and
% divides them into characters. 
% 
% Pages are asssumed to be images in directory PAGEDIR, with
% filename pattern PAGE_IMG_PATTERN.
%
% The characters are written in grayscale to directory CHARDIR.
% Additionally, monochromatic character images are placed in directory
% BW_CHARDIR.
%
% The algorithm is based on dilation and dividing the dilated
% image into regions. The structuring element should be picked
% to be large enough to connect parts within characters, and
% to be small enough to separate distinct characters.
% 
page_delay;                             % Delay for viewing page
delay=0.02;                             % Delay for viewing characters
pagedir='Pages';
page_img_pattern='page-%02d.ppm';
chardir='Chars';
bw_chardir='BWChars';
char_count=0;
se=strel('rectangle',[9,15]);
Type=2;                                 % Type of thresholding
Threshold=0.2;

for page=6:96

    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    I0=imread(filename);
    I1=255-I0; I2=im2bw(I1);
    %I2=binarize(I0,Type,Threshold);
    I3=imdilate(I2,se);
    imagesc(I3); drawnow; pause(delay);
    %[L,N]=bwlabel(I3,4);
    stats=regionprops(I3,...
                      'BoundingBox',...
                      'MajorAxisLength',...
                      'MinorAxisLength',...
                      'Orientation',...
                      'Image',...
                      'Centroid');
    %stats=sort_stats(stats);
    N=numel(stats);

    %imshow(I3);
    for n=1:N
        if filter_out(stats(n))
            continue;
        end
        J=zeros(size(I2));
        b=stats(n).BoundingBox;
        x1 = b(1); y1 = b(2); x2 = b(1) + b(3); y2 = b(2) + b(4);
        sz = size(I2);
        x1 = round( max(1,x1) ); x2 = round( min(x2, sz(2)));
        y1 = round( max(1,y1) ); y2 = round( min(y2, sz(1)));
        %K=stats(n).Image;
        K = I1( y1:y2, x1:x2 );
        BW = I2( y1 : y2, x1 : x2 );
        BW = imautocrop(BW);
        if filter_image(BW)
            continue
        end
        subplot(1,2,1),
        imagesc(K);
        subplot(1,2,2),
        imagesc(I2);
        r = rectangle('Position',b);
        set(r,'EdgeColor','red');
        title(sprintf('Page %d',page));
        drawnow;
        pause(delay);
        % Save character image
        char_count = char_count +1;
        imwrite(K, fullfile(chardir,sprintf('char%05d.png',char_count)), ...
                'PNG');
        imwrite(BW, fullfile(bw_chardir,sprintf('char%05d.pbm', ...
                                                char_count)),'PBM');
    end

end


function rv=filter_out(stat)
    rv=false;
    if stat.MinorAxisLength ./ stat.MajorAxisLength < 2e-1 && abs(stat.Orientation-90)<5
        rv=true;
    end

end

function rv=filter_image(K)
    rv=false;
    if size(K,1) > 100 || size(K,2) < 10
        rv=true;
    end
end

function sorted=sort_stats(stats)
    C=[stats.Centroid];
    [~, I] = sortrows(C);
    sorted=stats(I);
end


function [BW] = binarize(I,Type,Threshold)
% BWTHRESHOLD changes a color image to monochrome.
%  [BW] = BWTHRESHOLD(I,TYPE,THRESHOLD) changes a color image I to monochrome,
%  according to an integer TYPE grayscale first, then
%  using different methods based on Type, it changes the figure I to
%  grayscale and then to black and white.
%  THRESHOLD is defining the the threshold value; it is optional and the
%  default is 0.2
    if  nargin < 3
        Threshold=0.2;
    end
    Igray=rgb2gray(I);
    switch Type
      case 1 %Thresholdhold is fixed at 0.2
        T=Threshold;
      case 2 %Thresholdhold is global using Otsu Method
        T=('global');
        if  nargin == 3
            warning("Threshold parameter is not being used in Otsu Method!")
        end
      case 3 %Adaptive Filter using Mean Method
        T=adaptthresh(Igray,Threshold,'ForegroundPolarity','dark','Statistic','mean');
      case 4 %Adaptive Filter using Gaussian Method
        T=adaptthresh(Igray,Threshold,'ForegroundPolarity','dark','Statistic','gaussian');
      case 5 %Adaptive Filter using Median Method
        warning("Using Mean Method might be very time comsuming!")
        T=adaptthresh(Igray,Threshold,'ForegroundPolarity','dark','Statistic','median');
    end
    BW=~imbinarize(Igray,T);
end

