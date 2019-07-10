disp(mfilename);

pagedir='Pages';
page_img_pattern='page-%02d.ppm';
if ~exist('pages','var') pages=6:95; end;

%bg='Mono';
%bg='Foo';                               % Invalid option - test
bg='Original';
show_dilation = false;
show_outliers = false;


for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename);
    ps.show_marked_page_img('Background',bg,...
                            'ShowDilation',show_dilation,...
                            'ShowOutliers',show_outliers);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;