delay=0.02;
chardir='Chars';
bw_chardir='BWChars';
char_count=0;

for page=6:96

    filename=fullfile('Pages',sprintf('page-%02d.ppm',page));
    I1=255-imread(filename);
    I2=im2bw(I1);
    se=strel('rectangle',[9,15]);
    I3=imdilate(I2,se);
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
        imwrite(K, fullfile(chardir,sprintf('char%05d.png',char_count)), ...
                'PNG');
        imwrite(BW, fullfile(bw_chardir,sprintf('char%05d.pbm', ...
                                                char_count)),'PBM');
    end

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