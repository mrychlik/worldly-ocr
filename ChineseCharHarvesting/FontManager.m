classdef(Abstract) FontManager < handle
%FONTMANAGER - manages rendering of bitmaps of characters
    properties(Abstract)
        FontName;
        FontSize;
        Table;
    end

    methods(Abstract)
        BW = get_char_image(this, c)
    end
end