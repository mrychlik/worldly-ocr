%This script will get the chineese character and use Matlab OCR fucntion to
%guess them
clc;clear
for i=1:100
    imgname(i,:)=sprintf('char%05d.pbm',i);
end
dirpath='BWChars';  
figure; 

for jj=1:100
Address=fullfile(dirpath,imgname(jj,:));
%Address=fullfile('BWChars','Sample.png');
I   = imread(Address);
results=ocr(I,'Language','ChineseTraditional','TextLayout','Word')
% Sort the character confidences.
[sortedConf, sortedIndex] = sort(results.CharacterConfidences, 'descend');
% Keep indices associated with non-NaN confidences values.
indexesNaNsRemoved = sortedIndex( ~isnan(sortedConf) );
sortedConf= sortedConf( ~isnan(sortedConf) );
% Get the top ten indexes.
topTenIndexes = indexesNaNsRemoved(sortedConf>0.70);
% Select the top ten results.
digits = num2cell(results.Text(topTenIndexes));
bboxes = results.CharacterBoundingBoxes(topTenIndexes, :);

for ii=1:min(length(topTenIndexes),1)
    Text=sprintf('%s',char(digits(ii)));              %character
    label_str= [ char(digits(ii)), ' ', num2str(sortedConf(ii)*100,'%0.2f'),'%'];   %character and accuracy
    label_str
    %Idigits = insertObjectAnnotation(uint8(255 *I),'rectangle',bboxes,label_str);   %try to show them on the figure
    %figure, upper section
    subplot(2,1,1)
    imshow(I);
    %figure, lower section
    %subplot(2,1,2)
    drawTable({label_str})
    % text(0.5,0.5,label_str,'FontSize',40);axis off

    prompt = 'Do you think it is correct? (y/n)';
    ANSWER = input(prompt,'s');
    if ANSWER=='y'
       Data.Input{jj,1}=I;
      Data.Output{jj,1}=digits;
    end
end

end

sum(~cellfun(@isempty,Data.Input))
sum(~cellfun(@isempty,Data.Output))

%fulname = fullfile(dirpath,'100samples','Data');
%save(fulname,"Data")



function drawTable(Data)
 %     %%Change default character set
 %     defCharSet = feature('DefaultCharacterSet', 'UTF8');
 %     %%Add html tag to Data
 %     Data(:) = strcat('<html><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />', ...
 %                     Data(:));
    %%Plot figure and uitable
    f = gcf();
    subplot(2,1,1)
    Data
    t = uitable(f,'ColumnFormat',[],'Data',Data,'ColumnWidth',{400},'FontSize',40);
    t.Position = [20 20 500 100];
 %     %%Restore default char set
 %     feature('DefaultCharacterSet', defCharSet);
 end