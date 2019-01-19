function [Where,Count]=find_char_in_image(RefChar, I, InitialCount)
% Find occurrences of a character in an image
%  [WHERE,COUNT]=FIND_CHAR_IN_IMAGE(REFCHAR, I, INITIALCOUNT) finds the
% character REFCHAR in image I. WHERE will be set to the position
% of the objects in the order of objects found by REGIONPROPS.
% COUNT will be the count of occurrences of REFCHAR in I. If INITIALCOUNT
% is given, it will be added to the count.
%
if nargin < 3
    InitialCount=0;
end
Rthresh=0.4;                            % Detection threshold
DiamThresh=4;                           % Diameter threshold
NumModes=6;                             % Number of modes to consider
a=.0000001;                             % Regularizer
pause_time=5;                           % Time to pause on a solution
Padding=[6,6];                          % Padding around the ref. character

RefChar=padarray(RefChar,Padding,0,'both');

F=fft2(RefChar);

% Work with negative
objs=regionprops(I,'Image','Area','BoundingBox');

Where=zeros([numel(objs),1]);
Count=InitialCount;
for j=1:numel(objs)
    J=objs(j).Image;
    if size(J,1) < 12 || size(J,2) < 12
        continue
    end
    subplot(1,3,1),imshow(RefChar),
    title(sprintf('Size: [%d,%d], Count: %d',size(RefChar,1),size(RefChar,2),Count));
    J=padto(J,RefChar);
    if isempty(J) 
        continue
    end
    % H is target object in its context; we put J on the red plane
    % and the surroundings on blue
    H=zeros([size(J),3]);
    H(:,:,1)=J;
    r=objs(j).BoundingBox;
    xl=max(ceil(r(1)-Padding(1)),1);xh=min(floor(r(1)+r(3)+Padding(1)),size(I,2));
    yl=max(ceil(r(2)-Padding(2)),1);yh=min(floor(r(2)+r(4)+Padding(2)),size(I,1));
    K=I(yl:yh,xl:xh);
    L=padto(K,RefChar);
    if ~isempty(L)
        H(:,:,2)=L;
        H(:,:,3)=L;
    end
    subplot(1,3,2),imshow(H);
    title(['Character part: ',num2str(j)]),
    drawnow;
    G=fft2(J);
    R=(G.*conj(F))./(abs(F.*G)+a);
    RA=abs(ifft2(R));
    [Rmax,idx]=maxk(RA(:),NumModes);
    [k,l]=ind2sub(size(RefChar),idx);
    Goodness=sqrt(sum(Rmax.^2));
    subplot(1,3,3),imagesc(RA);
    title(sprintf('Goodness: %4.2f, Shift guess: [%2d,%2d]',...
                  Goodness,...
                  k(1),l(1))),
    colormap jet,
    drawnow;
    if (Goodness > Rthresh)
        diameter(size(RefChar),[k(1),l(1)],...
                 [k(2:end),l(2:end)]) < DiamThresh
        disp(Rmax);
        display([k,l]);
        Where(j)=1;
        Count=Count+1;
        pause(pause_time);
    end
end
Where=find(Where);
end

function J=padto(J,RefChar)
ht=size(RefChar,1)-size(J,1); ht=ceil(ht./2);
wd=size(RefChar,2)-size(J,2); wd=ceil(wd./2);
if ht < 1 || wd < 1 
    J=[];
    return;
end
J=padarray(J,[ht,wd],0,'pre');
ht=size(RefChar,1)-size(J,1);
wd=size(RefChar,2)-size(J,2);    
J=padarray(J,[ht,wd],0,'post');
end

