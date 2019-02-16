if ~exist('cropped','var')
    load('cropped.mat')
end
transpose=false;                        % Work with rotated image
win=5;                                  % Window
epsilon=1e-2;                           % epsilon

% First image
idx0 = 100;
% Second image
idx = 102;

I0 = cropped(idx0).image;
I0 = 255 - I0;

I =cropped(idx).image;
I = 255 - I;

% Scale both to the same size
[I_scaled,I0_scaled] = scale_both(I,I0);
% Make an RGB version of I

J0=zeros([size(I0_scaled),3]);
J0(:,:,1)=I0_scaled;
J0(:,:,2)=I0_scaled;        
J0(:,:,3)=I0_scaled;                


J=zeros([size(I_scaled),3]);
J(:,:,1)=I_scaled;
J(:,:,2)=I_scaled;        
J(:,:,3)=I_scaled;                

clf;


for x = (size(I_scaled,2)-win):-1:0
    col0 = double( I0_scaled(:,(x+1):(x+win)) )./255;
    col  = double( I_scaled(:,(x+1):(x+win)))./255;

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
