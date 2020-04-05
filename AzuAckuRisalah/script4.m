imgfname = fullfile('images','LineOfPashto.png');
BW = imread(imgfname);
psm = 7;
language = 'pus';                       % Pashto
% language = 'fas';                       % Persian
r = TesseractRecognizer(psm,language);
[str,status] = r.recognize(BW);