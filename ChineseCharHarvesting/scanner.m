%
% This script scans through the pages of a book in Chinese and
% divides them into characters. 
% 
% Pages are asssumed to be images in directory PAGEDIR, with
% filename pattern PAGE_IMG_PATTERN.
%
% The characters are written in grayscale to directory CHARDIR.
% Additionally, monochromatic character images are placed in directory
% BW_CHARDIR.
%
% The algorithm is based on dilation and dividing the dilated
% image into regions. The structuring element should be picked
% to be large enough to connect parts within characters, and
% to be small enough to separate distinct characters.
% 
page_delay=0;                             % Delay for viewing page
delay=0.02;                             % Delay for viewing characters
pagedir='Pages';
% filename patterns
page_img_pattern='page-%02d.ppm';
box_file_pattern='page-%02d.txt';
char_img_pattern='page%02-char%05d.pbm';
bw_char_img_pattern='page%02-char%05d.png';

chardir='Chars';
bw_chardir='BWChars';
se=strel('rectangle',[9,15]);
boxdir='Boxes';

parfor page=6:96
    char_count=0;
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    I0=imread(filename);
    I1=255-I0; I2=im2bw(I1);
    %I2=binarize(I0,Type,Threshold);
    I3=imdilate(I2,se);
    imagesc(I3); drawnow; pause(page_delay);
    %[L,N]=bwlabel(I3,4);
    stats=regionprops(I3,...
                      'BoundingBox',...
                      'MajorAxisLength',...
                      'MinorAxisLength',...
                      'Orientation',...
                      'Image',...
                      'Centroid');
    %stats=sort_stats(stats);
    N=numel(stats);
    boxfilename=fullfile(boxdir,sprintf(box_file_pattern,page));
    fid = fopen(boxfilename,'w');

    %imshow(I3);
    for n=1:N
        if filter_out(stats(n))
            continue;
        end
        J=zeros(size(I2));
        b=stats(n).BoundingBox;
        x1 = b(1); y1 = b(2); x2 = b(1) + b(3); y2 = b(2) + b(4);
        sz = size(I2);
        x1 = round( max(1,x1) ); x2 = round( min(x2, sz(2)));
        y1 = round( max(1,y1) ); y2 = round( min(y2, sz(1)));
        %K=stats(n).Image;
        K = I1( y1:y2, x1:x2 );
        BW = I2( y1 : y2, x1 : x2 );
        BW = imautocrop(BW);
        if filter_image(BW)
            continue
        end
        subplot(1,2,1),
        imagesc(K);
        subplot(1,2,2),
        imagesc(I2);
        r = rectangle('Position',b);
        set(r,'EdgeColor','red');
        title(sprintf('Page %d',page));
        drawnow;
        pause(delay);
        % Save character image
        char_count = char_count +1;
        imwrite(BW, fullfile(bw_chardir,sprintf(char_img_pattern, ...
                                                page,char_count)),'PBM');
        imwrite(K, fullfile(chardir,sprintf(bw_char_img_pattern,...
                                            page,char_count)), 'PNG');
        % Write box info
        fprintf(fid, '%d %d %d %d\n', y1, x1, y2, x2);
    end
    fclose(fid);

end


function rv=filter_out(stat)
    rv=false;
    if stat.MinorAxisLength ./ stat.MajorAxisLength < 2e-1 && abs(stat.Orientation-90)<5
        rv=true;
    end

end

function rv=filter_image(K)
    rv=false;
    if size(K,1) > 100 || size(K,2) < 10
        rv=true;
    end
end

function sorted=sort_stats(stats)
    C=[stats.Centroid];
    [~, I] = sortrows(C);
    sorted=stats(I);
end
