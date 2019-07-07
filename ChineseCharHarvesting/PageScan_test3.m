pagedir='Pages';
page_img_pattern='page-%02d.ppm';

for page=6:95
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan;
    ps = ps.scanfile(filename);
    ps.show_centroids;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;