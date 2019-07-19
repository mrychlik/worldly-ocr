disp(mfilename);

config_pages;

keep_outliers=false;
num_lines=12;

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps.show_vertical_lines('NumberOfLines', num_lines);
    %title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;