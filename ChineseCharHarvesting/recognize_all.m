datadir='BWChars';
out='OutputsAsUTF8';
image_files = dir(fullfile(datadir,'*.pbm'));
num_files = numel(image_files);

bh=waitbar(0,'Recognizing',num2str(num_files), 'characters...');
for f=1:num_files
    waitbar(f/num_files, bh);
    fname=image_files(f).name;
    fbase=fname(1:end-4);
    fpath = fullfile(datadir, fname);
    BW = imread(fpath);
    imshow(BW), drawnow;
    chi_str=recognize(BW);
    txt_fname=fullfile(out,[fbase,'.txt']);
    fh = fopen(txt_fname,'wb+');
    fwrite(fh,chi_str,'char');
    fclose(fh);
end
close(bh);