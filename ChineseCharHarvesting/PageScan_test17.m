% Run Tesseract on character skeletons

disp(mfilename);

config_pages;

keep_outliers=false;
radius = 2;
se = strel('disk',radius);

r = TesseractRecognizer('Language','chi_tra','PageSegmentationMode',10);

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps = ps.do_merge_characters_all;

    for i=1:ps.CharacterCount
        I = ps.Characters(i).CroppedMonoImage;
        Iskel = bwskel(I);
        Iskel = imdilate(Iskel, se);
        %I = padarray(I,[10 10],0,'both');
        str = r.recognize(~Iskel);
        imagesc(Iskel);
        title(str(1),'FontSize',100);
        pause(0.5);
    end
    ps.show_ocr;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;


