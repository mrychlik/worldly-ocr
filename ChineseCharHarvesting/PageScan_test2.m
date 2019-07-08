pagedir='Pages';
page_img_pattern='page-%02d.ppm';

%for page=6:95
for page=6:10
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename);
    ps.show_short_chars_img;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;