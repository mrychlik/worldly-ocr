datadir='BWChars';
out='OutputsAsUTF8';
image_files = dir(fullfile(datadir,'*.pbm'));
num_files = numel(image_files);

bh=waitbar(0,['Recognizing ', num2str(num_files), ' characters...']);
for f=1:num_files
    if(mod(f,10)==0)
        frac=f/num_files;
        waitbar(frac, bh,['Recognition ', num2str(frac*100),'% done...']);
    end
    fname=image_files(f).name;
    fbase=fname(1:end-4);
    fpath = fullfile(datadir, fname);
    BW0 = imautocrop(imread(fpath));
    BW = padarray(BW0,[10 10],0,'both');
    %imshow(BW), drawnow;
    chi_str=recognize(BW);
    txt_fname=fullfile(out,[fbase,'.txt']);
    fh = fopen(txt_fname,'wb+');
    fwrite(fh,chi_str,'char');
    fclose(fh);
end
waitbar(1, bh,'Done');
close(bh);