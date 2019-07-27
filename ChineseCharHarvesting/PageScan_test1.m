disp(mfilename);


config_pages;

bg='Mono';
%bg='Foo';                               % Invalid option - test
%bg='Original';

% Pack options in a structure
opts.KeepOutliers = false;
opts.ShowDilation = true;
opts.ShowOutliers = false;


for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps.show_marked_page_img(opts);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;