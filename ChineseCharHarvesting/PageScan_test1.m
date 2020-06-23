disp(mfilename);


config_pages;

% Pack options in a structure
opts_main.KeepOutliers = false;

% opts.Background = 'Mono';
opts_show.Background = 'Original';
opts_show.ShowDilation = true;
opts_show.ShowOutliers = false;


for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,opts_main);
    ps.show_marked_page_img(opts_show);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;