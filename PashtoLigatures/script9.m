if ~exist('sparse_ligatures','var')
    load('sparse.mat')
end
transpose=false;                        % Work with rotated image
win=5;                                  % Window
epsilon=1e-2;                           % epsilon

% First image
idx0 = 100;

% Second image
idx = 101;                              % Use the same image as demo

I0 = sparse_ligatures(idx0).image;
I0 = 255 - I0;

I = sparse_ligatures(idx).image;
I = 255 - I;

% Make an RGB version of I
J0 = zeros([size(I0),3]);
J0(:,:,1) =I0;
J0(:,:,2) =I0;
J0(:,:,3) =I0;

J = zeros([size(I),3]);
J(:,:,1) = I;
J(:,:,2) = I;
J(:,:,3) = I;

clf;


for x = (size(I,2)-win):-1:0
    col0 = double( I0(:,(x+1):(x+win)) )./255;
    col  = double( I(:,(x+1):(x+win)))./255;

    K0=J0;
    K0(:,(x+1):(x+win),1) = 255;
    K0(:,(x+1):(x+win),2) = 0;        
    K0(:,(x+1):(x+win),3) = 0;        


    K=J;
    K(:,(x+1):(x+win),1) = 255;
    K(:,(x+1):(x+win),2) = 0;        
    K(:,(x+1):(x+win),3) = 0;        


    subplot(2,3,1), imshow(K0), colormap(gray);
    subplot(2,3,4), imshow(K), colormap(gray);

    subplot(2,3,2), imshow(col0);
    subplot(2,3,5), imshow(col);

    L0 = fft2(col0);
    L = fft2(col);
    M = abs( ifft2( (L .* conj(L0)) ./( epsilon + abs(L).*abs(L0) ) ) ...
             );
    M = circshift(M,round(size(M)/2));
    subplot(2,3,[3,6]), imshow(M), colormap(hot);
    drawnow;
end
