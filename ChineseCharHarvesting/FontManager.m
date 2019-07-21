classdef(Abstract) FontManager 
%FONTMANAGER - manages rendering of bitmaps of characters
%  FONTMANAGER implements caching of generated bitmaps in memory.
%  Since the manager does not use persistent storage, the cache goes away
%  when the FONTMANAGER object is destroyed.
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