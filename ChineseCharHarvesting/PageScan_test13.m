disp(mfilename);

pagedir='Pages';
page_img_pattern='page-%02d.ppm';
if ~exist('pages','var') pages=6:95; end;
keep_outliers=false;

r = TesseractRecognizer;

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps = ps.do_merge_characters_all;

    for i=1:ps.CharacterCount
        BW = ps.Characters(i).CroppedMonoImage;
        BW = padarray(~BW,[10 10],0,'both');
        str=r.recognize(BW);
        imshow(BW);
        title(str(1));
        pause(2);
    end
    ps.show_ocr;
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;


