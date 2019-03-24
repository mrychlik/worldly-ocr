% Test of Google translator wrapper

fname = 'LineOfPashto.txt';             % File wish Pashto text

g=GoogleTranslator;
fh=fopen(fname);
str = native2unicode(fread(fh,'uint8')','UTF-8');
g.translate_string(str)
g.translate_file(fname)


