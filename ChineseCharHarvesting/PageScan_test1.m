pagedir='Pages';
page_img_pattern='page-%02d.ppm';

%bg='Mono';
%bg='Foo';                               % Invalid option - test
bg='Original';

for page=6:95
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan;
    ps = ps.scanfile(filename);
    ps.marked_page_img(bg);
    drawnow;
    pause;
end;