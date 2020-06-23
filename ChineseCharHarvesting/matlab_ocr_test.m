disp(mfilename);

pagedir='Pages';
page_img_pattern='page-%02d.ppm';

page=6;
filename=fullfile(pagedir,sprintf(page_img_pattern,page));
ps = PageScan(filename);

chi_sim_td='tesseract-ocr/tessdata/chi_tra.traineddata';

txt=ocr(ps.PageImage,'Language', {chi_sim_td});