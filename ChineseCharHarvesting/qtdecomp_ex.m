%%    View the block representation of quadtree decomposition.

%I = imread('liftingbody.png');
I0 = imread('Pages3/page-06.ppm');
I1 = rgb2gray(I0);
sz = size(I1);
log2_sz = ceil(log2(sz));
I=padarray(I1,2.^log2_sz-sz,0,'post');

thresh = 0.5;
S = qtdecomp(I,thresh,16);
blocks = repmat(uint8(0),size(S));
for dim = [16 8 4 2 1];    
    numblocks = length(find(S==dim));    
    if (numblocks > 0)        
        values = repmat(uint8(1),[dim dim numblocks]);
        values(2:dim,2:dim,:) = 0;
        blocks = qtsetblk(blocks,S,dim,values);
    end
end
blocks(end,1:end) = 1;
blocks(1:end,end) = 1;
imshow(I),

figure,
hold on;

blocks = blocks(1:sz(1),1:sz(2));
im1 = image(blocks);
im1.AlphaData = 0.5;

I=I(1:sz(1),1:sz(2));
im2 = image(I);
im2.AlphaData = 0.5;

hold off;