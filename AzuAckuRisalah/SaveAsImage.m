% This is the faster version script3.m which also saves each line the final
% processed image seperately. 

% Address of the folder the image we want to read is located
dirpath='Pages';                %direction of the original image
dirpathsave='imagesamples';     %direction for saving each line
imgname='page-14.ppm';
% reading and processing the figure and save the resaults in obj
imgfile=fullfile(dirpath,imgname);
I=imread(imgfile);
imshow(I);
BW=BWThreshold(I,1);
obj = LineBreaker(BW);
obj.SigmaFactor=1;                      % To be experimentally determined
obj=merge_short_lines(obj);
% saving each line seperately
if(exist(dirpathsave,'dir') )
    rmdir(dirpathsave,'s');
end
mkdir(dirpathsave)
for label=1:max(max(obj.LabeledLines))
    IMAGE=obj.LabeledLines==label;
    IMAGEBox=box(IMAGE);
    imshow(IMAGEBox); 
    %pause(1); 
    name=sprintf('image%03.0f.png',label);
    fulname = fullfile(dirpathsave,name);
    imwrite(IMAGEBox,fulname); 
end




function IMAGEBox=box(BW)
            % it crop the image based on the black background
            [I,J]=find(BW);
            BBox=[min(J),min(I),range(J),range(I)];
            IMAGEBox=imcrop(BW,BBox);
end
        
        
        
        
        