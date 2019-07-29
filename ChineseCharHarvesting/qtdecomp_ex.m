%%    View the block representation of quadtree decomposition.

%I = imread('liftingbody.png');
I0 = imread('Pages3/page-06.ppm');
I1 = rgb2gray(I0);
I2 = im2bw(I0);

sz = size(I1);
log2_sz = ceil(log2(sz));
I=padarray(I1,2.^log2_sz-sz,0,'post');

thresh = 0.5;
S = qtdecomp(I,thresh);
blocks = repmat(uint8(0),size(S));
for dim = [32,16 8 4 2 1];    
    numblocks = length(find(S==dim));    
    if (numblocks > 0)        
        values = repmat(uint8(1),[dim dim numblocks]);
        values(2:dim,2:dim,:) = 0;
        blocks = qtsetblk(blocks,S,dim,values);
    end
end
blocks(end,1:end) = 1;
blocks(1:end,end) = 1;
hold on;

subplot(1,2,1);
I=I(1:sz(1),1:sz(2));
imshow(I),



subplot(1,2,2);
blocks = blocks(1:sz(1),1:sz(2));
im1 = imshow(blocks,[]);
im1.AlphaData = 0.5;

I2=imdilate(I2,strel('rectangle',[2,2]));
im2 = imshow(I2);


hold off;