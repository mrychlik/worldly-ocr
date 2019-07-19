disp(mfilename);

config_pages;

keep_outliers=false;

r = TesseractRecognizer('Language','chi_tra','PageSegmentationMode',10);

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps = ps.do_merge_characters_all;

    for i=1:ps.CharacterCount
        I = ps.Characters(i).CroppedMonoImage;
        I = padarray(I,[10 10],0,'both');
        str = r.recognize(~I);
        imagesc(I);
        title(str(1),'FontSize',100);
        pause(2);
    end
    ps.show_ocr;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;


