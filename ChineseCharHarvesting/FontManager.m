classdef FontManager < handle
    properties(Access=private)
        FontCache;                      % Cache of character images
        opts;                           % Options passed to constructor
    end

    properties(Dependent)
        FontName;
        FontSize;
        ItemCount;
    end


% Responsible for rendering and caching Unicode characters
    methods
        function this = FontManager(varargin)
            p = inputParser;
            addParameter(p, 'FontName', 'TimesRoman', @(x)ischar(x));
            addParameter(p, 'FontSize', 100, @(x)isscalar(x));            
            parse(p, varargin{:});
            
            this.opts = p.Results;
            this.FontCache = containers.Map('KeyType','char','ValueType','any');
        end

        function BW = get_char_image(this, c)
            if isKey(this.FontCache, c)
                s = this.FontCache(c);
                BW = s.Image;
                this.FontCache(c).HitCount = s.HitCount + 1;
            else
                BW = this.draw_unicode_char(c);
                this.FontCache(c) = struct('Image',BW,'HitCount',1);
            end
        end
        
        function FontName = get.FontName(this)
            FontName = this.opts.FontName;
        end
        function FontSize = get.FontSize(this)
            FontSize = this.opts.FontSize;
        end
        function ItemCount = get.ItemCount(this)
            ItemCount = this.FontCache.size();
        end
    end

    methods(Access = private)
        function BW = draw_unicode_char(this, c) 
        % DRAW_UNICODE_CHAR - draw a single unicode character
        %   BW = DRAW_UNICODE_CHAR(C, FONT, FONTSIZE) draws
        %   Unicode character C in font FONT, using font size
        %   FONTSIZE in pixels. It returns the generated image
            fh = figure('Units', 'pixels', 'Color', [1,1,1],'visible','off');
            ax = axes(fh,'Position',[0 0 1 1],'Units','Normalized','visible','off');
            axis off;

            th = text(ax, 0,0,c,...
                      'FontName', this.opts.FontName,...
                      'FontSize', this.opts.FontSize, ...
                      'Interpreter','none',...
                      'Units', 'pixels',...
                      'HorizontalAlignment','Left',...
                      'VerticalAlignment','Bottom');

            ex = get(th,'Extent');
            F = getframe(fh);
            BW = im2bw(F.cdata);
            [h,~] = size(BW);
            bbox = round([ex(1)+1,h-ex(4)-1,ex(3),ex(4)]);
            BW = BW( bbox(2):(bbox(2)+bbox(4)), bbox(1):(bbox(1)+bbox(3)));
            
            delete(fh);
        end

    end
end