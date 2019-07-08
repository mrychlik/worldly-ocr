pagedir='Pages';
page_img_pattern='page-%02d.ppm';
show_outliers=false;


for page=6:95
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename);
    ps.show_rows('ShowOutliers',show_outliers);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;