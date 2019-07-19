config_num = 1;

switch config_num
  case 1,
    pagedir='Pages';
    page_img_pattern='page-%02d.ppm';
  case 2,
    pagedir='Pages2';
    page_img_pattern='page-%03d.ppm';
  case 3,
    pagedir='Pages3';
    page_img_pattern='page-%02d.ppm';
end

if ~exist('pages','var') pages=6:95; end;
