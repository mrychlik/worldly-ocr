ligature_dir=fullfile('Ligatures');
ligature_files = dir(fullfile(ligature_dir,'*.bmp'));
text_dir=fullfile('Outputs');

num_files = length(ligature_files);
enc = 'UTF8';                           % Encoding
fontsz=50;

for f = 1:num_files
    fname = ligature_files(f).name;
    disp(fname);
    fpath = fullfile(ligature_dir, fname);
    [~,fbase,ext] = fileparts(fname)
    tfpath = fullfile(text_dir,[fbase,'.txt']);subplot(2,1,1),
    disp(tfpath);
    fd=fopen(tfpath,'r');
    bytes=fread(fd,'uint8')';
    fclose(fd);
    clf;
    subplot(1,2,1),
    plot([],[]);
    t=text(0.5,0.3,native2unicode(bytes, enc)); set(t,'FontSize',fontsz);
    I=imread(fpath);
    subplot(1,2,2),imagesc(I), colormap(gray),drawnow;
    pause(1);
end