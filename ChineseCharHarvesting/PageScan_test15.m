disp(mfilename);

config_pages;

keep_outliers = false;

% waitfun=@()uiwait(gcf);
waitfun=@()pause(.2);


% NOTE: This is needed as a workaround, because font manager now uses a hidden figure, which
% would be used for drawing OCR results. 
set(gcf,'Visible','on');
movegui(gcf,'center');
for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    set(gcf, 'name', sprintf('Page %d', page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers,...
                  'FontManager', font_manager);
    ps.do_merge_characters_all;
    ps.show_ocr_slowly;
    title(sprintf('Page %d', page));
    drawnow;
    waitfun;
end;