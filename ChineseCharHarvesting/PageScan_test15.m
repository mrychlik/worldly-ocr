disp(mfilename);

pagedir='Pages';
page_img_pattern='page-%02d.ppm';
if ~exist('pages','var') pages=6:95; end;

%bg='Mono';
%bg='Foo';                               % Invalid option - test
keep_outliers = true;
show_dilation = false;
show_outliers = false;


for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps.show_ocr;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;