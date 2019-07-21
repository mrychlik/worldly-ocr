classdef(Abstract) FontManager 
%FONTMANAGER - manages rendering of bitmaps of characters
    properties(Access=private);
        opts;                           % Options passed to constructor
    end

    properties(Abstract)
        FontName;
        FontSize;
        Table;
    end

    methods(Abstract)
        BW = get_char_image(this, c)
        BW = draw_unicode_char(this, c) 
    end
end