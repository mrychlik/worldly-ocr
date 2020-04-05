% Test of Google translator wrapper

txtdir='Text';

%fname = 'LineOfPashto.txt';             % File wish Pashto text
%fname = fullfile(txtdir, 'page-14.txt');
fname = fullfile(txtdir, 'page-13.txt');

g=GoogleTranslator;
fh=fopen(fname);
str = native2unicode(fread(fh,'uint8')','UTF-8');
fclose(fh);
g.translate_string(str)
g.translate_file(fname)


