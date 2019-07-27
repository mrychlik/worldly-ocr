disp(mfilename);


config_pages;

% Pack options in a structure
opts_main.KeepOutliers = false;

% opts.Background = 'Mono';
opts.Background = 'Original';
opts.ShowDilation = true;
opts.ShowOutliers = false;


for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,opts_main);
    ps.show_marked_page_img(opts);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;