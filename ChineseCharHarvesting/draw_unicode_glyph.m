function glyph=draw_unicode_glyph(u,fontname,fontsize)
% Create an image representation of a unicode glyph
%  GLYPH=DRAW_UNICODE_GLYPH(U,FONTNAME,FONTSIZE) creates
% a GLYPH, which is a structure, containing fields
% UNICODE, BWIMAGE, BBOX and CROPPEDIMAGE.
% The fields represent the following
%   UNICODE - the passed value U;
%   BWIMAGE - monochrome image representing the rasterized
%             character;
%   BBOX    - the bounding box of the character pixels within
%             its BWIMAGE.
%   CROPPEDIMAGE - the image of the character cropped to its bounding box.
    if nargin < 2
        fontname='TimesRoman';
    end
    if nargin < 3
        fontsize=160;
    end
    clf;
    I=RasterizeText(char(u),fontname,fontsize);
    imshow(I), drawnow;
    glyph.unicode=u;
    glyph.bwimage=I;    
    [J,rect]=imautocrop(I);
    glyph.bbox=rect;
    glyph.croppedimage=J;
end