disp(mfilename);

config_pages;

keep_outliers = false;


for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps = ps.do_merge_characters_all;
    ps.show_ocr_slowly;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;