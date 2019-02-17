if ~exist('sparse_ligatures','var')
    load('sparse.mat')
end
transpose=false;                        % Work with rotated image
win=5;                                  % Window
epsilon=1e-2;                           % epsilon

% First image
idx0 = 1;
I0 = sparse_ligatures(idx0).image;
I0 = 255 - I0;

% Make an RGB version of I
J0 = zeros([size(I0),3]);
J0(:,:,1) =I0;
J0(:,:,2) =I0;
J0(:,:,3) =I0;


for idx = 1:nsamples

    I = sparse_ligatures(idx).image;
    I = 255 - I;


    J = zeros([size(I),3]);
    J(:,:,1) = I;
    J(:,:,2) = I;
    J(:,:,3) = I;

    clf;


    M = min(size(I,2),size(I0,2));
    for x = (M-win):-1:0
        col0 = I0(:,(x+1):(x+win)) );
        col  = I(:,(x+1):(x+win))) );

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

        subplot(2,3,2), imagesc(col0);
        subplot(2,3,5), imagesc(col);

        L0 = fft2(col0);
        L = fft2(col);
        M = abs( ifft2( (L .* conj(L0)) ./( epsilon + abs(L).*abs(L0) ) ) ...
                 );
        M = circshift(M,round(size(M)/2));
        subplot(2,3,[3,6]), imagesc(M), colormap(hot);
        drawnow;
    end
end