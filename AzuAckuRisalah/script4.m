% Tests TesseractRecognizer
% Performs OCR on a line of text.
%imgfname = fullfile('images','LineOfPashto.png');
imgfname = fullfile('imagesamples','image001.png');
BW = imread(imgfname);
psm = 7;
%language = 'pus';                       % Pashto
language = 'fas';                       % Persian
r = TesseractRecognizer(psm,language);
[str,status] = r.recognize(BW);