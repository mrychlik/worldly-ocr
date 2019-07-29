%%    View the block representation of quadtree decomposition.

%I = imread('liftingbody.png');
I0 = imread('Pages3/page-06.ppm');
I1 = rgb2gray(I0);                      % Must make an intensity image
I2 = im2bw(I0);

sz = size(I1);
log2_sz = ceil(log2(sz));
I = padarray(I1,2.^log2_sz-sz,0,'post');

thresh = 0.28;
S = qtdecomp(I,thresh);
blocks = repmat(uint8(0),size(S));

for dim = [256,128,64,32,16 8 4];    
    %c = 10*ceil(log2(dim));              % color
    c=uint8(255);
    numblocks = length(find(S==dim));    
    if (numblocks > 0)        
        values = repmat(c,[dim dim numblocks]);
        %values(2:dim,2:dim,:) = c;
        blocks = qtsetblk(blocks,S,dim,values);
    end
end

blocks(end,1:end) = 1;
blocks(1:end,end) = 1;


ax1=subplot(1,3,1);
I = I(1:sz(1),1:sz(2));
imshow(I,[]),

ax2=subplot(1,3,[2,3]);
blocks = blocks(1:sz(1),1:sz(2));
imshow(blocks,[]);

linkaxes([ax1,ax2]);


