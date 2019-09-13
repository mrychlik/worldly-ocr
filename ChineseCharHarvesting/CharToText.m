%This script will get the chineese character and use Matlab OCR fucntion to
%guess them
clc;clear
for i=1:100
    imgname(i,:)=sprintf('char%05d.pbm',i)
end
dirpath='BWChars';   
Address=fullfile(dirpath,imgname(1));
%Address=fullfile('BWChars','Sample.png');
I   = imread(Address);
results=ocr(I,'Language','ChineseTraditional','TextLayout','Word')
% Sort the character confidences.
[sortedConf, sortedIndex] = sort(results.CharacterConfidences, 'descend');
% Keep indices associated with non-NaN confidences values.
indexesNaNsRemoved = sortedIndex( ~isnan(sortedConf) );
sortedConf= sortedConf( ~isnan(sortedConf) );
% Get the top ten indexes.
topTenIndexes = indexesNaNsRemoved(sortedConf>0.25);
% Select the top ten results.
digits = num2cell(results.Text(topTenIndexes));
bboxes = results.CharacterBoundingBoxes(topTenIndexes, :);
for ii=1:length(digits)
    sprintf('%s',char(digits(ii)))
    label_str{ii} = [ char(digits(ii)), ' ', num2str(sortedConf(ii)*100,'%0.2f'),'%'];
end
label_str
Idigits = insertObjectAnnotation(uint8(255 *I),'rectangle',bboxes,label_str);
figure; 
subplot(2,1,1)
text(0.5,0.5,label_str,'FontSize',40);axis off
subplot(2,1,2)
imshow(Idigits);









% This is the faster version script3.m which also saves each line the final
% processed image seperately. 

% Address of the folder the image we want to read is located
dirpathsave='imagesamples';     %direction for saving each line    

for i=1:length(imgname)
    % saving each line seperately
    imgfileLine=fullfile(dirpath,dirpathsave,imgname(i));
    if(exist(imgfileLine,'dir') )
        rmdir(imgfileLine,'s');
    end
    mkdir(imgfileLine)
    for label=1:max(max(obj.LabeledLines))
        IMAGE=obj.LabeledLines==label;
        
        imshow(IMAGEBox);
        %pause(1);
        name1=sprintf('image%03.0f.png',label);
        fulname = fullfile(imgfileLine,name1);
        imwrite(~IMAGEBox,fulname);
    end

end



