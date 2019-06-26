% Tests TesseractRecognizer
% Performs OCR on a line of text.
%imgfname = fullfile('images','LineOfPashto.png');
clc;clear
dirpathsave='imagesamples';     %direction for saving each line
for lablel=1:1
name1=sprintf('image%03.0f.png',lablel);
imgfname = fullfile(dirpathsave,name1);
BW = imread(imgfname);
imshow(BW);
psm = 7;
language = 'pus';                       % Pashto
r = TesseractRecognizer(psm,language);
[str1,status1] = r.recognize(BW);

language = 'fas';                       % Persian
r = TesseractRecognizer(psm,language);
[str2,status2] = r.recognize(BW);

Difference=str1-str2;
sum(Difference)
if sum(Difference)~=0 
    warning("pus and fas are not the same!")
end



name2=sprintf('image%03.0f.txt',lablel);
fulname = fullfile(dirpathsave,name2);
dlmwrite(str1,fulname); 

end