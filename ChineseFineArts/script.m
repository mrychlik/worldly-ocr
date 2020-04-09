% Parameters to decode a page of this newspaper 
filepath=fullfile('..','images','38059-000001.png');
I=imread(filepath);
BW = im2bw(I,0.8);