if ~exist('X','var')
    load('training_data');
end
N=size(X,2);
Xr=reshape(X,[max_h,max_w,N]);
IC=vec2ind(T);                          % Convert one-hot encoded class to index
for k=1:N; 
    clf;
    subplot(1,2,1);
    BW=Xr(:,:,k);
    imagesc(BW);
    title(sprintf('Character %d',k));
    xlim([1,max_w]);
    ylim([1,max_h]);
    subplot(1,2,2);
    chi_str=recognize(BW);
    chi_text(chi_str);
    title(sprintf('Label %s', chi_str));
    drawnow;
    pause(2); 
end


function chi_text(str)
% Draw the characters
    font='Arial';
    fontsize=64;
    hold on;
    s=text(0, 0, str, ...
           'FontSize', fontsize,...
           'FontName',font);
    r=s.Extent;
    q=rectangle('Position',[r(1),r(2),r(3)-r(1),r(4)-r(2)],'LineWidth',3);
    m=0;                                % Margin
    xlim([r(1)-m,r(3)+m]);
    ylim([r(2)-m,r(4)+m]);
    hold off;
end

function [str, status] = recognize(BW)
%RECOGNIZE Perform OCR on a BW image.
% [STR, STATUS] = RECOGNIZE(BW) takes a binary image BW and
% performs OCR on it. Upon success, as string STR is returned
% and STATUS is set to 0.
% Upon failure, STATUS is non-zero.
    fname = tempname;
    imwrite(BW, fname, 'PNG');
    base = fname;
    lang='chi_tra';
    dpi=70;
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

