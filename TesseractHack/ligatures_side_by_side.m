ligature_dir=fullfile('Ligatures');
ligature_files = dir(fullfile(ligature_dir,'*.bmp'));
text_dir=fullfile('Outputs');

num_files = length(ligature_files);
enc = 'UTF8';                           % Encoding

for f = 1:num_files
    fname = ligature_files(f).name;
    disp(fname);
    fpath = fullfile(ligature_dir, fname);
    [~,fbase,ext] = fileparts(fname)
    tfpath = fullfile(text_dir,[fbase,'.txt']);
    disp(tfpath);
    fd=fopen(tfpath,'r');
    bytes=fread(fd,'uint8')';
    fclose(fd);
    clf;
    subplot(1,2,1), t=text(0,0,native2unicode(bytes, enc)), set(t,'FontSize',20);
    I=imread(fpath);
    subplot(1,2,2),imshow(I), drawnow;
    pause(.2);
end