pagedir='Pages';
page_img_pattern='page-%02d.ppm';
show_outliers=false;
keep_outliers=true;

for page=6:95
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps.show_column_centers;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;