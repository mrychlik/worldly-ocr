% this script saves each line of the obj as a picture to be used by tesseract later

if(exist('imagesamples','dir') )
    rmdir('imagesamples','s');
end
mkdir('imagesamples')


for label=1:max(max(obj.LabeledLines))
    imshow(obj.LabeledLines==label); 
    %pause(1); 
    name=sprintf('image%03.0f.png',label);
    fulname = fullfile('imagesamples',name);
    imwrite(obj.LabeledLines==label,fulname); 
end