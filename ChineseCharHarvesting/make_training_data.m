bw_chardir='BWChars';
txt_dir='OutputsAsUTF8';

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
    max_w = max(w, max_w);    
end
close(bh);

X=zeros(max_h,max_w,N);
for char_count=1:N
    [h,w]=size(BW{char_count});
    y_off=round((max_h-h)/2);
    x_off=round((max_w-w)/2);
    X((y_off+1):(y_off+h),(x_off+1):(x_off+w),char_count)=BW{char_count};
end

save('training_data.mat','X','-v7.3');

for char_count=1:N
    char_count
    txtfile=fullfile(txt_dir,sprintf('char%05d.txt', char_count));
    [fid, msg]=fopen(txtfile,'r');
    if ~isempty(msg)
        error(sprintf('Could not open file %s: message: %s',txtfile, msg));
    end
    [bytes,count]=fread(fid,'uint8');
    str=native2unicode(bytes);
    str=str(1:(end-1));
    str
    fclose(fid);
end