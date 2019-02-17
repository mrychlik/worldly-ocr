%
% Apply Haar wavelet to ligatures, visualize results
%
if ~exist('ligatures','var')
    load('ligatures.mat');
end

max_levels=3;

for idx=1:size(ligatures,3)
    I=ligatures(:,:,idx);
    I=255-I;
    [xmin,xmax]=bounds(find(sum(I,1)));
    [ymin,ymax]=bounds(find(sum(I,2)));
    I=I(ymin:ymax,xmin:xmax);
    nlevels=min(max_levels,floor(log2(min(size(I)/2))));
    [A,H,V,D]=haart2(I,nlevels,'integer');    


    for j=1:nlevels
        subplot(3,nlevels,j);
        imagesc(D{j});
        title(['D-',num2str(j)]);;
        subplot(3,nlevels,nlevels+j);
        imagesc(H{j});
        title(['H-',num2str(j)]);
        subplot(3,nlevels,2*nlevels+j);
        imagesc(I);
        title('Original image');
    end
    pause(2);
end