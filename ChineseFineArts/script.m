% Parameters to decode a page of this newspaper 
filepath=fullfile('..','Data','38059-000001.png');
I=imread(filepath);
BW = binarize(I,'adaptive','ForegroundPolarity','dark','Seinsitivity',0.8);