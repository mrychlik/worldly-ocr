bw_chardir='BWChars';
for char_count=1:16002
    BW=imwread(fullfile(bw_chardir,sprintf('char%05d.pbm', char_count));
    imshow(BW),drawnow;
    pause(1);
end