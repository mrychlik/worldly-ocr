disp(mfilename);


config_pages;

%bg='Mono';
%bg='Foo';                               % Invalid option - test
bg='Original';
keep_outliers = false;
show_dilation = true;
show_outliers = false;


for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps.show_marked_page_img('Background',bg,...
                            'ShowDilation',show_dilation,...
                            'ShowOutliers',show_outliers);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;