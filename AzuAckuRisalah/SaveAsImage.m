% This is the faster version script3.m which also saves each line the final
% processed image seperately. 

% Address of the folder the image we want to read is located
clc;clear;
dirpath='Pages';                %direction of the original image
dirpathsave='imagesamples';     %direction for saving each line
imgname       =PageCaller();       

for i=1:length(imgname)
    % reading and processing the figure and save the resaults in obj
    imgfile=fullfile(dirpath,imgname(i));
    I=imread(imgfile);
    imshow(I);
    BW=BWThreshold(I,1);
    obj = LineBreaker(BW);
    obj.SigmaFactor=1;                      % To be experimentally determined
    obj=merge_short_lines(obj);
    % saving each line seperately
    imgfileLine=fullfile(dirpathsave,imgname(i));
    if(exist(imgfileLine,'dir') )
        rmdir(imgfileLine,'s');
    end
    mkdir(imgfileLine)
    for label=1:max(max(obj.LabeledLines))
        IMAGE=obj.LabeledLines==label;
        IMAGEBox=box(IMAGE);
        imshow(IMAGEBox);
        %pause(1);
        name1=sprintf('image%03.0f.png',label);
        fulname = fullfile(imgfileLine,name1);
        imwrite(~IMAGEBox,fulname);
    end

end


function IMAGEBox=box(BW)
            % it crop the image based on the black background
            Margin=5;
            [I,J]=find(BW);
            BBox=[min(J)-Margin,min(I)-Margin,range(J)+2*Margin,range(I)+2*Margin];
            IMAGEBox=imcrop(BW,BBox);
end
        
        
        
        
        