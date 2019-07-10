disp(mfilename);

pagedir='Pages';
page_img_pattern='page-%02d.ppm';
if ~exist('pages','var') pages=6:95; end;

show_bboxes=false;
%for page=6:95
for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename);
    ps.show_short_chars_img('ShowBoundingBoxes',show_bboxes);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;