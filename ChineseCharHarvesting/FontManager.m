classdef FontManager < handle
    properties(Constant)
        Font = 'TimesRoman';
        FontSize = 100;
    end


% Responsible for rendering and caching Unicode characters
    methods
        function this = FontManager
        end

        function BW = get_char_image(this, c)
            BW = this.draw_unicode_char(c, this.Font, this.FontSize);
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
                      'FontSize', this.FontSize, ...
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