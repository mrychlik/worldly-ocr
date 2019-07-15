fid = fopen(fullfile('Tesseract_results','page-06.txt'));
b = fread(fid,'*uint8')';
fclose(fid);

str = native2unicode(b);
disp(str);

f=figure;
set(f,'Visible','off');
g=draw_unicode_glyph(str,'Helvetica',100);
delete(f);