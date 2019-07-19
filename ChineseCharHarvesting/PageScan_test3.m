disp(mfilename);

config_pages;

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename);
    ps.show_centroids;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;