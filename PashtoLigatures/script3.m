%
% Apply varous wavelest to ligatures, visualize results
%


if ~exist('ligatures','var')
    load('ligatures.mat');
end

%% Presents DWT of ligatures
%wname='db1';
wname='db2';
%wname='coif1';
%wname='coif2';
%wname='bior1.1';


for idx=1:size(ligatures,3)
    I=ligatures(:,:,idx);
    I=255-I;
    [xmin,xmax]=bounds(find(sum(I,1)));
    [ymin,ymax]=bounds(find(sum(I,2)));
    I=I(ymin:ymax,xmin:xmax);
    % First level DWT
    [A,H,~,D] = dwt2(I,wname);
    % Second level DWT
    [A2,~,~,~] = dwt2(A,wname);
    subplot(5,1,1);
    imagesc(D);
    title('Diagonal');
    subplot(5,1,2);
    imagesc(H);
    title('Horizontal')
    subplot(5,1,3);
    imagesc(A);
    title('A1')
    subplot(5,1,4);
    imagesc(A2);
    title('A2');
    subplot(5,1,5);
    imagesc(I);
    title('Original image');
    pause(2);
end