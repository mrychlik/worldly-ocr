function [J,rect]=imautocrop(I,varargin)
% Crop an image automatically
%  [J,RECT]=IMAUTOCROP(I) accepts a monochrome image I
% and it returns in J the smallest image containing all non-zero
% pixels of I. RECT is set to the bounding box of J in I.
%
    p=inputParser;
    addRequired(p,'I',@(x)any([isnumeric(x),islogical(x)]));
    defaultDirection='both';
    validDirections={'vertical','horizontal','both'};
    checkDirection=@(x)any(validatestring(x,validDirections));
    addOptional(p,'Direction',defaultDirection, checkDirection);

    parse(p,I,varargin{:});

    if strcmp(p.Results.Direction,'both') || ...
            strcmp(p.Results.Direction,'horizontal')
        [xl,xh]=bounds(find(sum(I,1) > 0));
    else
        xl=1; xh=size(I,2);
    end
    if strcmp(p.Results.Direction,'both') || ...
            strcmp(p.Results.Direction,'vertical')
        [yl,yh]=bounds(find(sum(I,2) > 0));
    else
        yl=1; yh=size(I,1);
    end

    rect=[xl-0.5,yl-0.5,xh-xl+1,yh-yl+1];
    J=I(yl:yh,xl:xh);
end
