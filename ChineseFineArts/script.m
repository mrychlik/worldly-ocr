% Parameters to decode a page of this newspaper 
filepath=fullfile('..','Data','38059-000001.png');
I=imread(filepath);
BW = imbinarize(I,'adaptive','ForegroundPolarity','dark','Sensitivity',0.5);