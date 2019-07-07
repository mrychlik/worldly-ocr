pagedir='Pages';
page_img_pattern='page-%02d.ppm';

%bg='Mono';
%bg='Original';
bg='Foo';
for page=6:96
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan;
    ps = ps.scanfile(filename);
    ps.marked_page_img(bg);
    drawnow;
    pause;
end;