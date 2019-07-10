pagedir='Pages';
page_img_pattern='page-%02d.ppm';
if ~exist('pages','var') pages=6:95; end;

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename);
    ps.show_centroids;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;