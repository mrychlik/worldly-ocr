bw_chardir='BWChars';
% Compuute common bounding box
N=16002;
BW=cell(N,1);
max_h = 0; max_w = 0;
bh=waitbar(0,'Computing common bounding box size...');
for char_count=1:N
    waitbar(char_count/N,bh);
    imfile=fullfile(bw_chardir,sprintf('char%05d.pbm', char_count));
    BW{char_count}=imread(imfile);
    %imshow(BW{char_count}),drawnow;
    [h,w]=size(BW{char_count});
    max_h = max(h, max_h);
    max_2 = max(h, max_w);    
end
close(bh);