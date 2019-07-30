%%    View the block representation of quadtree decomposition.

%I = imread('liftingbody.png');
I0 = imread('Pages3/page-06.ppm');
I1 = rgb2gray(I0);                      % Must make an intensity image
I2 = im2bw(I0);

sz = size(I1);
log2_sz = ceil(log2(sz));
I = padarray(I1,2.^log2_sz-sz,0,'post');

S = qtdecomp(I,@thresh);
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
I = I(1:sz(1),1:sz(2));
imshow(I,[]),

ax2=subplot(1,2,2);
blocks = blocks(1:sz(1),1:sz(2));
imshow(blocks,[]);

linkaxes([ax1,ax2]);

% S = QTDECOMP(I,FUN) uses the function FUN to determine whether to split a
% block. QTDECOMP calls FUN with all the current blocks of size M-by-M
% stacked into M-by-M-by-K array, where K is the number of M-by-M
% blocks. FUN should return a logical K-element vector whose values are 1 if
% the corresponding block should be split, and 0 otherwise.  FUN must be a
% FUNCTION_HANDLE.
function rv = thresh(B)
    [m,m,k] = size(B);
    disp(m);
    rv = ones(k,1,'logical');
    for j=1:k
        [Small,Large] = bounds( B(:,:,k), 'all' )
        if Large - Small < 64
            rv(j) = logical(0);
        end
    end
    disp(rv');
end
