% Tests TesseractRecognizer
% Performs OCR on a line of text.
%imgfname = fullfile('images','LineOfPashto.png');
% This script reads the lines already saved in imagesamples folder then
        % 1) uses them as the input for Tessaract and save the output as a
        % text file
        % 2) saves the whole input and output in a matlab data file,
        % Data.mat
clc;clear
dirpathsave='imagesamples';     %direction for saving each line
imgname       =PageCaller();     
enc = 'UTF-8';
Lang=1;                          %You can chose 
                                                    %1 for Pashto
                                                    %2 for Persian
                                                    %3 for Comparing them
for i=1:length(imgname)                                            
imgfname = fullfile(dirpathsave,imgname(i),'*.png');
for lablel=1:numel(dir(imgfname))
name1=sprintf('image%03.0f.png',lablel);
imgfname = fullfile(dirpathsave,imgname(i),name1);
BW = imread(imgfname);
imshow(BW);
psm = 7;
switch Lang 
    case 1
        language = 'pus';                       % Pashto
        r = TesseractRecognizer(psm,language);
        [str1,status1] = r.recognize(BW);
    case 2
        language = 'fas';                       % Persian
        r = TesseractRecognizer(psm,language);
        [str1,status1] = r.recognize(BW);
    case 3
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
end

name2=sprintf('image%03.0f.txt',lablel);
fulname = fullfile(dirpathsave,imgname(i),name2);
fid=fopen(fulname,'w','n',enc);
fprintf(fid,'%s',native2unicode(str1,enc));
fclose('all');

Data.Input{i,lablel}=BW;
Data.Output{i,lablel}=str1;
end
end
fulname = fullfile(dirpathsave,"Data");
save(fulname,"Data")
