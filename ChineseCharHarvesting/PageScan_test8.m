pagedir='Pages';
page_img_pattern='page-%02d.ppm';
keep_outliers=false;

for page=11
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    BW = ps.Boundary;
    [H,T,R] = hough(BW,'Theta',-90:0.5:89);
    imshow(imadjust(rescale(H)),'XData',T,'YData',R/250,...
           'InitialMagnification','fit');
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;

