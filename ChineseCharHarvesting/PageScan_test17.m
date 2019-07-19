% Run Tesseract on character skeletons

disp(mfilename);

config_pages;

keep_outliers=false;
radius = 2;
se = strel('disk',radius);
padding = [5 5];

r = TesseractRecognizer('Language','chi_tra','PageSegmentationMode',10);

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps = ps.do_merge_characters_all;

    ignored = [ps.Character.Ignore];
    for i=1:ps.CharacterCount
        if ignore(i)
            continue;
        end
        I = ps.Characters(i).CroppedMonoImage;
        Iskel = bwskel(I);
        Iskel = imdilate(Iskel, se);
        Iskel = padarray(Iskel,padding,0,'both');
        str = r.recognize(~Iskel);
        imagesc(Iskel);
        title(str(1),'FontSize',100);
        pause(1);
    end
    ps.show_ocr;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;


