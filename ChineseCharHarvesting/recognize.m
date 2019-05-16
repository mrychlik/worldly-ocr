function [str, status] = recognize(BW)
%RECOGNIZE Perform OCR on a BW image.
% [STR, STATUS] = RECOGNIZE(BW) takes a binary image BW and
% performs OCR on it. Upon success, as string STR is returned
% and STATUS is set to 0.
% Upon failure, STATUS is non-zero.
    fname = tempname;
    imwrite(~BW, fname, 'PNG');         % Work with negative B on white
    base = fname;
    lang='chi_tra';
    %lang='chi_tra_vert';
    dpi=300;
    psm=10;	
    oem=1;
    cmd = sprintf('tesseract --psm %d --dpi %d, -l %s %s %s', ...
                  psm, dpi, lang, fname, base);
    [status,result] = system(cmd);
    delete(fname);
    if status == 0
        txtfname=fullfile([base,'.txt']);
        fh = fopen(txtfname,'r');
        bytes = fread(fh, 'uint8')';
        fclose(fh);
        delete(txtfname);
        try
            str = native2unicode(bytes,'UTF-8');
        catch ME
            rethrow(ME);
        end
    end
end
