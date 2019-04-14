bw_chardir='BWChars';
txt_dir='OutputsAsUTF8';

% Compuute common bounding box
N=16002;
O=[15986,15993];                                % The outliers

BW=cell(N,1);
max_h = 0; max_w = 0;
bh=waitbar(0,'Computing common bounding box size...');
for char_count=1:N
    if find(char_count==O,1)
        continue;
    end
    waitbar(char_count/N,bh);
    imfile=fullfile(bw_chardir,sprintf('char%05d.pbm', char_count));
    BW{char_count}=imread(imfile);
    %imshow(BW{char_count}),drawnow;
    [h,w]=size(BW{char_count});
    max_h = max(h, max_h);
    max_w = max(w, max_w);    
end
close(bh);

% Make centered images of the characters, and wrap in a 3D array
X=zeros(max_h,max_w,N);
for char_count=1:N
    if find(char_count==O,1)
        continue;
    end
    [h,w]=size(BW{char_count});
    y_off=round((max_h-h)/2);
    x_off=round((max_w-w)/2);
    X((y_off+1):(y_off+h),(x_off+1):(x_off+w),char_count)=BW{char_count};
end

% Read the labels, obtained by other means (e.g. Tesseract or human OCR).
str=cell(N,1);
for char_count=1:N
    txtfile=fullfile(txt_dir,sprintf('char%05d.txt', char_count));
    [fid, msg]=fopen(txtfile,'r');
    if ~isempty(msg)
        error(sprintf('Could not open file %s: message: %s',txtfile, msg));
    end
    [bytes,count]=fread(fid,'uint8');
    str{char_count}=native2unicode(bytes');
    fclose(fid);
end

% Find the unique labels
[C,IA,IC] = unique(str);

% Number of classes
NC=numel(IA);
% One-hot encoding of the classes
T=ind2vec(IC',NC);

% Make a standard training dataset, with linearized images as columns
X=reshape(X,[max_h*max_w,N]);

save('training_data.mat','X','T','max_h','max_w','-v7.3');

