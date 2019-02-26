% To render content of a file with UTF8 text, we need to read the
% file as bytes and then draw the bytes.
%
% The bytes were obtained like this, from a text file
fd = fopen('Outputs/P1_226_567.txt','r'); bytes = fread(fd,'uint8');bytes=bytes'; fclose(fd);

%bytes = [ 45 217 131 218 134 219 144 10 10]';
enc = 'UTF8';                           % Encoding
t=text(0,0,native2unicode(bytes, enc));
set(t,'FontSize',100);