% Run Tesseract on character skeletons

disp(mfilename);

config_pages;

keep_outliers=false;
%se = strel('disk',2);
se = strel('rectangle',[2,2]);
padding = [5 5];

r = TesseractRecognizer('Language','chi_tra','PageSegmentationMode',10);

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
        Ipad = padarray(I, padding, 0, 'both');
        Iskel = imdilate(Iskel, se);
        Iskel = bwskel(I);
        Iskel = imdilate(Iskel, se);
        Iskel = padarray(Iskel,padding,0,'both');
        str1 = r.recognize(~Iskel);
        str2 = r.recognize(~Ipad);
        subplot(1,2,1);
        imagesc(Iskel);
        title(str1,'FontSize',100);
        subplot(1,2,2);
        imagesc(I);
        title(str2,'FontSize',100);
        pause(2);
    end
    ps.show_ocr;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;


