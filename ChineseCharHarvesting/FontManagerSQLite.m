classdef FontManagerSQLite < handle
%FONTMANAGER - manages rendering of bitmaps of characters
%  FONTMANAGER implements caching of generated bitmaps in memory.
%  Since the manager does not use persistent storage, the cache goes away
%  when the FONTMANAGER object is destroyed.
    properties(Access=public)
        conn;
    end
    properties(Access=public);
        opts;                           % Options passed to constructor
    end

    properties(Dependent)
        FontName;
        FontSize;
        Table;
    end


% Responsible for rendering and caching Unicode characters
    methods
        function this = FontManagerSQLite(varargin)
            p = inputParser;
            addParameter(p, 'FontName', 'TimesRoman', @(x)ischar(x));
            addParameter(p, 'FontSize', 100, @(x)isscalar(x));
            addParameter(p, 'DBFileName', 'font.db', @(x)ischar(x));
            parse(p, varargin{:});
            
            this.opts = p.Results;
            this.connect_db;
        end

        function delete(this)
            close(this.conn);
        end

        function connect_db(this)
            if exist(this.opts.DBFileName, 'file') ~= 2
                mode = 'create';
            else
                mode = 'connect';
            end
            this.conn = sqlite(this.opts.DBFileName, mode);
            exec(this.conn, [ 'create table if not exists bitmaps ' ...
                              '(char VARCHAR, ' ...
                              'image VARCHAR, ' ...
                              'hitcount NUMERIC)' ]);
        end

        function BW = get_char_image(this, c)
            results = fetch(this.conn, [ 'select image from bitmaps ' ...
                                'where char = ''', c, '''']);
            if isempty(results) 
                BW = this.draw_unicode_char(c);
                BW = imautocrop(BW);
                BW_data = pack_binary_image(BW);
                insert(this.conn, 'bitmaps',...
                       {'char', 'image', 'hitcount'},...
                       {c, char(BW_data), 1} );
            else
                results = results(1);
                BW_data = results{2};
                BW = unpack_binary_image(BW_data);
            end
        end
        
        function FontName = get.FontName(this)
            FontName = this.opts.FontName;
        end
        function FontSize = get.FontSize(this)
            FontSize = this.opts.FontSize;
        end
    end

    methods(Access = public)
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