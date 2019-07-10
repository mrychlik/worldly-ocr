disp(mfilename);

pagedir='Pages';
page_img_pattern='page-%02d.ppm';
if ~exist('pages','var') pages=6:95; end;

show_outliers=false;
keep_outliers=false;
show_bboxes=true;

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps.show_column_centers('ShowOutliers',show_outliers, 'ShowBoundingBoxes',show_bboxes);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;