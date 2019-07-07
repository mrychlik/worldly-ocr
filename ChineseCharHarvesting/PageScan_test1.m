pagedir='Pages';
page_img_pattern='page-%02d.ppm';

%bg='Mono';
%bg='Foo';                               % Invalid option - test
bg='Original';
show_dilation = true;

%for page=6:95
for page=6
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan;
    ps = ps.scanfile(filename);
    ps.show_marked_page_img('Background',bg,'ShowDilation',show_dilation);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;