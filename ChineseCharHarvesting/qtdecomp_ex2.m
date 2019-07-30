%%    View the block representation of quadtree decomposition.

%I = imread('liftingbody.png');
I0 = imread('Pages3/page-06.ppm');
I1 = rgb2gray(I0);                      % Must make an intensity image

sz = size(I1);
log2_sz = ceil(log2(sz));
I = padarray(I1,2.^log2_sz-sz,max(I1(:)),'post');
imagesc(I); pause(1);

S = qtdecomp(I, @split_test);
blocks = repmat(uint8(0),size(S));

for dim = [256,128,64,32,16 8 4 2 1];    
    c = 10*ceil(log2(dim));              % color
    numblocks = length(find(S==dim));    
    if (numblocks > 0)        
        values = repmat(uint8(255),[dim dim numblocks]);
        values(2:dim,2:dim,:) = c;
        blocks = qtsetblk(blocks,S,dim,values);
    end
end

blocks(end,1:end) = 1;
blocks(1:end,end) = 1;

figure;

ax1=subplot(1,2,1);
I_orig = I(1:sz(1),1:sz(2));
imshow(I_orig,[]),

ax2 = subplot(1,2,2);
blocks_orig = blocks(1:sz(1),1:sz(2));
imshow(blocks_orig,[]);

linkaxes([ax1,ax2]);

% S = QTDECOMP(I,FUN) uses the function FUN to determine whether to split a
% block. QTDECOMP calls FUN with all the current blocks of size M-by-M
% stacked into M-by-M-by-K array, where K is the number of M-by-M
% blocks. FUN should return a logical K-element vector whose values are 1 if
% the corresponding block should be split, and 0 otherwise.  FUN must be a
% FUNCTION_HANDLE.
function rv = split_test(B)
    [m,m,k] = size(B);
    display(m);
    rv = ones(1,k,'logical');
    for j=1:k
        imshow( B(:,:,k) ), drawnow, pause(1);
        M = median( B(:,:,k), 'all' )
        if M < 10
            rv(j) = logical(0);
        end
    end
    display(rv);
end
