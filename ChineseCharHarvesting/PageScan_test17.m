% Run Tesseract on character skeletons

disp(mfilename);

config_pages;

keep_outliers=false;
se = strel('disk',1);
%se = strel('rectangle',[4,4]);
padding = [5 5];

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps = ps.do_merge_characters_all;

    ignored = [ps.Characters.Ignore];
    for i=1:ps.CharacterCount
        if ignored(i)
            continue;
        end
        I = ps.Characters(i).CroppedMonoImage;
        Iskel = bwskel(I);
        Iskel = imdilate(Iskel, se);
        Iskel = padarray(Iskel,padding,0,'both');
        str = ps.OcrText(i);
        imagesc(Iskel);
        title(str(1),'FontSize',100);
        pause(2);
    end
    ps.show_ocr;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;


