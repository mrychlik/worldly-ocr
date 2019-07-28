classdef PageScan < handle
% PAGESCAN - class representing a scanned page
% This class inherits from HANDLE class, so that we can internally
% modify fields, such as caches.
    properties(Constant,Access=private)
        % Add supported language options here, Tesseract style. Note that
        % these options may depend on TesseractVersion option to the constructor.
        SupportedLanguages = ...
            {
                'chi_tra_vert', ...
                'chi_tra_simp', ...
                'ChineseTraditional',...
                'ChineseSimplified'
            };
    end

    properties
        DilationSE = strel('rectangle', [5,15]); % for imdilate
        Characters = [];
        PageImage = [];
        PageImageMono = [];
        DilatedImage = [];
    end

    properties(Access=public)
        ExternalOcrResultsCache = [];   % A cache of OCR results from OS Tesseract
        MexOcrResultsCache = [];        % A cache of OCR results from Mex rapper
        opts = [];                      % Various options
        FontManager;                    % A caching font manager
    end


    properties(Dependent)
        CharacterCount;                 % Number of identified characters
        Centroids;               % Character centroids - CharacterCount-by-2
        HorizontalRanges;            % Horizontal extends of characters.
        Columns;                        % Column assignment
        Rows;                           % Row assignment
        ColumnCount;                    % Number of columns
        RowCount;                       % Number of rows
        ColumnCenters;                  % X of the column mean centroid
        Width;                          % Image width
        Height;                         % Image height
        Size;                           % Image size: [h,w]
        Boundary;                       % Page boundary
        HorizontalBoundary;             % Top and bottom of page
        % VerticalBoundary              % Currently function, as we want to pass some options
        Binding;                        % Information about book binding
        MergeCharacters;
        ROI;                            % An Nx4 array, rows are char. boxes
        OcrResults;                     % Output of OCR on ROI
        Source;                         % File or image
    end


    methods
        function this = PageScan(varargin)
        %PAGESCAN - Constructor
        % THIS = PAGESCAN(SOURCE) constructs a page scan of a SOURCE,
        % which can be a filename or a numeric array representing the
        % page image. Optional arguments:
        %
        %   * KeepOutliers - if true all objects in the image are kept, even
        %   if they do not look like characters.
        %   * MergeCharacters - if true, automatically try to merge
        %     short (i.e. not tall) characters into bigger ones
        %
        %   * TesseractVersion - either 'builtin', 'external' or 'mex'; if
        %     'builtin' then Vision Toolkit 'ocr' function is invoked to
        %     perform OCR; if 'external', the version of Tesseract available
        %     to the OS is invoked
        %
        %   * ShortHeightThreshold - below this height the character is
        %     short
        %
        %   * ColumnDistThreshold  - distinct columns must be at least
        %     this pixels apart
        % 
        %   * RowDistThreshold     - distinct rows must be at least this
        %     pixels apart
        % 
        %   * MergeThreshold       - only merge if bboxes of characters
        %     are this pixels apart in vert. direction
        % 
        %   * MaxCharWidth - objects wider than this pixels are not considered characters
        % 
        %   * MinCharHeight        - objects shorter than this are not characters
        % 
        %   * BinThreshold         - used to binarize images
        % 
        %   * MinVertGap           - The minimum vertical gap between bboxes
        % 
        %   * LanguageSpec         - language specification
        %     One way to specify the language is by giving the path to
        %     trained data. These files Must be compatible with the version
        %     of Tesseract used in MATLAB, currently 3.0.2.
        %     where Tesseract data are, e.g. for Traditional Chinese
        %     language_spec = {'tesseract-ocr/tessdata/chi_tra.traineddata',...
        %                      'tesseract-ocr/tessdata/chi_sim.traineddata'};
        %
        %   * Font                 - the name of the font for rendering
        %
        %   * FontSize             - font size used for rendering
        % 
        %   * FontManager          - an external FontManager object, used
        %                            for rendering character images
        % 
        %  NOTE TO DEVELOPERS: If you have an option to the constructor
        %  which you would like to add, do not add a property. Instead,
        %  use the addOption(p,...) in the code of the
        %  constructor. Add documentation above.
            p = inputParser;

            addOptional(p, 'Source', [], @(x)(ischar(x)||isnumeric(x)));
            addParameter(p, 'KeepOutliers', false, @(x)islogical(x));            
            addParameter(p, 'MergeCharacters', false, @(x)islogical(x));
            addParameter(p, 'TesseractVersion', 'mex',...
                        @(x)any(validatestring(x,{'builtin','external','mex'})));
            addParameter(p, 'ShortHeightThreshold', 30, @(x)isscalar(x));
            addParameter(p, 'ColumnDistThreshold', 50, @(x)isscalar(x));
            addParameter(p, 'RowDistThreshold', 40, @(x)isscalar(x));        
            addParameter(p, 'MergeThreshold', 20, @(x)isscalar(x));
            addParameter(p, 'MaxCharWidth', 100, @(x)isscalar(x));
            addParameter(p, 'MinCharHeight',10, @(x)isscalar(x));
            addParameter(p, 'MaxCharHeight',100, @(x)isscalar(x));            
            addParameter(p, 'BinThreshold', 0.45, @(x)isscalar(x));
            addParameter(p, 'MinVertGap', 10, @(x)isscalar(x));
            addParameter(p, 'LanguageSpec', 'ChineseTraditional',...
                         @(x)any(validatestring, this.SupportedLanguages));
            addParameter(p, 'FontName', 'TimesRoman', @(x)ischar(x));
            addParameter(p, 'FontSize', 60, @(x)isscalar(x));
            addParameter(p, 'FontManager', [], @(x)isa(x,'FontManager'));
            parse(p, varargin{:});

            this.opts = p.Results;

            if isempty(this.opts.FontManager)
                this.FontManager = FontManagerRAM('FontName', this.opts.FontName, ...
                                                  'FontSize', this.opts.FontSize);
            else 
                this.FontManager = this.opts.FontManager;
                % We should never use 'FontManager' option so we delete it
                this.opts = rmfield(this.opts,'FontManager');
            end

            % If source provided, initialize for this source
            if ~isempty(this.opts.Source)
                this.update_source(this.opts.Source);
            end

        end

        function this = set.Source(this, Source)
            this.update_source(Source);
        end

        function update_source(this, Source);
            this.opts.Source = Source;
            if ischar(Source)
                filename = Source;
                img = imread(filename);
            elseif isnumeric(Source)
                img = Source;
            else
                error('First argument must be a filename or an image');
            end
            this.scan_image(img);
            
            if this.opts.MergeCharacters
                this.do_merge_characters_all;
            end
        end

        function Source = get.Source(this)
            Source = this.opts.Source;
        end

        function CharacterCount = get.CharacterCount(this)
            CharacterCount = numel(this.Characters);
        end

        function ColumnCount = get.ColumnCount(this)
            ColumnCount = max(this.Columns);
        end

        function RowCount = get.RowCount(this)
            RowCount = max(this.Rows);
        end

        function Centroids = get.Centroids(this)
            fh = @(s)s.Stats.Centroid';
            Centroids = cell2mat(arrayfun(fh,this.Characters,'UniformOutput',false))';
            % Set to empty array with 2 columns, to avoid exceptional
            % processing when page is empty
            if isempty(Centroids)
                Centroids = zeros(0,2);
            end
        end

        function Width = get.Width(this)
            Width = size(this.PageImageMono,2);
        end

        function Height = get.Height(this)
            Height = size(this.PageImageMono,1);
        end

        function Size = get.Size(this)
            Size = size(this.PageImageMono);
        end

        function ROI = get.ROI(this)
            ROI = zeros(this.CharacterCount, 4);
            for char_idx = 1:this.CharacterCount
                bbox = this.Characters(char_idx).Stats.BoundingBox;                
                [x,y,w,h] = dbox(bbox);
                ROI(char_idx,:) = [x,y,w,h];
            end
        end

        function OcrResults = get.OcrResults(this)
            char_idx = 1:this.CharacterCount;
            roi = this.ROI(char_idx, :);

            % NOTE: Tesseract results are significantly better when
            % the grayscale is passed rather than monochrome image
            OcrResults = ocr(this.PageImage, roi,...
                             'TextLayout','Character',...
                             'Language', this.opts.LanguageSpec);

        end

        function ExternalOcrResults = ExternalOcrResults(this, char_idx)
            if isempty(this.ExternalOcrResultsCache)
                this.updateExternalOcrResultsCache;
            end
            nargchk(nargin, 1, 2);
            if nargin < 2 
                char_idx = 1:this.CharacterCount;
            end
            ExternalOcrResults = this.ExternalOcrResultsCache(char_idx);
        end

        function MexOcrResults = MexOcrResults(this, char_idx)
            if isempty(this.MexOcrResultsCache)
                this.updateMexOcrResultsCache;
            end
            nargchk(nargin, 1, 2);
            if nargin < 2 
                char_idx = 1:this.CharacterCount;
            end
            MexOcrResults = this.MexOcrResultsCache(char_idx);
        end

        function OcrText = OcrText(this, char_idx)
            nargchk(nargin, 1, 2);
            if nargin < 2 
                char_idx = 1:this.CharacterCount;
            end
            switch this.opts.TesseractVersion,
              case 'builtin',
                OcrText = {this.OcrResults(char_idx).Text};
                % Replace blanks with '?'
                OcrText = strrep(OcrText, ' ', '?');
              case 'external',
                OcrText = {this.ExternalOcrResults(char_idx).Text};                
                % Replace blanks with '?'
                OcrText = strrep(OcrText, ' ', '?');
              case 'mex',
                OcrText = {this.MexOcrResults(char_idx).Text};                
            end
        end


        function show_ocr(this, varargin)
        % SHOW_OCR - show the Unicode characters 
        % SHOW_OCR(THIS) displays Unicode characters discovered by the
        % OCR subsystem. The positions of the characters are aligned
        % with the bounding boxes discovered by our page segmentation.
        % The figure is split into two subplots: left and right.
        % The left plot shows the original page image. The right
        % one shows the original page image as semi-transparent
        % background. The axes of the subplots are linked,
        % so that zoom and pan are synchronized.
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p,'CharIndices', 1:this.CharacterCount, ...
                        @(x)(isnumeric(x) &&  ...
                             min(x) >= 1  && ...
                             max(x) <= this.CharacterCount) ...
                        );
            addParameter(p, 'FontSize', 40,  @(x)isscalar(x));
            parse(p, this,varargin{:});

            % Do not show characters marked as ignored
            ignored=find([this.Characters.Ignore]);
            char_idx = setdiff(p.Results.CharIndices, ignored);

            c = this.ROI(char_idx,:);
            x = c(:,1); y = c(:,2); w = c(:,3); h = c(:,4);

            ax1 = subplot(1,2,1);
            im1 = imagesc(ax1, ~this.PageImageMono);
            this.draw_bounding_boxes('CharacterIndices', char_idx,'ShowOutliers',true);
            colormap(gray);

            ax2 = subplot(1,2,2);

            set(ax1,'Position',[.05,.05,.425,.95]);
            set(ax2,'Position',[.55,.05,.425,.95]);

            set (ax2,'YDir','reverse');

            hold on;
            im2 = imagesc(~this.PageImageMono);
            im2.AlphaData = 0.1;

            label_str = this.OcrText(char_idx);

            % Label color is dependent on version of Tesseract
            switch this.opts.TesseractVersion
              case 'builtin',
                color = 'blue';
              case 'external',
                color = 'magenta';
              case 'mex',
                color = 'red';
            end


            % NOTE: Set interpreter to one, as the default is 'latex'
            % and will not like backslashes
            lab = text(x, y, label_str,...
                       'FontSize',p.Results.FontSize,...
                       'Color',color,...
                       'Clipping','on',...
                       'Interpreter','none',...
                       'HorizontalAlignment','Left',...
                       'VerticalAlignment','Top');
            
            %h = zoom; % get handle to zoom utility
                      %set(h,'ActionPostCallback',@zoomCallBack);
            %set(h,'Enable','on');

            % This makes zoom and pan synchronous for both axes
            linkaxes([ax1,ax2]);
            hold off;

            
            % everytime you zoom in, this function is executed
            function zoomCallBack(~, evd)      
            % Since i expect to zoom in ax(4)-ax(3) gets smaller, so fontsize
            % gets bigger.
                ax = axis(evd.Axes); % get axis size
                                     % change font size accordingly      
                set(lab,'FontSize', p.Results.FontSize * (ax(4)-ax(3))); 
            end

        end


        function show_ocr_slowly(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p,'CharIndices', 1:this.CharacterCount, ...
                        @(x)(isnumeric(x) &&  ...
                             min(x) >= 1  && ...
                             max(x) <= this.CharacterCount) ...
                        );
            parse(p, this,varargin{:});

            % Do not show characters marked as ignored
            ignored=find([this.Characters.Ignore]);
            char_idx = setdiff(p.Results.CharIndices, ignored);

            c = this.ROI(char_idx,:);
            x = c(:,1); y = c(:,2); w = c(:,3); h = c(:,4);


            ax1 = subplot(1,2,1);
            im1 = imagesc(ax1, ~this.PageImageMono);
            this.draw_bounding_boxes('CharacterIndices', char_idx,'ShowOutliers',true);
            colormap(gray);

            ax2 = subplot(1,2,2);

            set(ax1,'Position',[.05,.05,.425,.95]);
            set(ax2,'Position',[.55,.05,.425,.95]);


            set (ax2,'YDir','reverse');

            hold on;
            im2 = imagesc(~this.PageImageMono);
            im2.AlphaData = 0.1;

            label_str = this.OcrText(char_idx);

            bh = waitbar(0,'Rendering character images from Unicode...');
            len = numel(label_str);
            for i = 1:len
                waitbar(i/len,bh);
                BW = this.FontManager.get_char_image(label_str{i});
                %imagesc(Font.Bitmaps{1}); drawnow; pause(2);
                I = imresize(BW,[h(i),w(i)]);
                im = image(x(i),y(i),255*I);
            end
            close(bh);

            % This makes zoom and pan synchronous for both axes
            linkaxes([ax1,ax2]);
            hold off;
        end

        function ColumnCenters = get.ColumnCenters(this)
            ColumnCenters = zeros(this.ColumnCount, 1);
            for col=1:this.ColumnCount
                ColumnCenters(col) = mean(this.Centroids(this.Columns == col,1));
            end
        end

        function  HorizontalRanges = get.HorizontalRanges(this)
            fh = @(s)bbox_hor_range(s.Stats.BoundingBox)';
            HorizontalRanges = cell2mat(arrayfun(fh,this.Characters,'UniformOutput',false))';
        end


        function show_marked_page_img(this,varargin)
        % MARKED_PAGEIMAGE shows page with character bounding boxes
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'Axes', [], @axes_test_fun);
            addParameter(p, 'Background', 'Original',...
                        @(x)any(validatestring(x,{'Original','Mono'})));
            addParameter(p, 'ShowCentroids', true, @(x)islogical(x));
            addParameter(p, 'ShowDilation', false, @(x)islogical(x));            
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));
            addParameter(p, 'ShowHorizontal', true, @(x)islogical(x));
            addParameter(p, 'ShowVertical', true, @(x)islogical(x));
            addParameter(p, 'EraseVerticalLines', true, @(x)islogical(x));

            parse(p, this,varargin{:});

            ax = p.Results.Axes;
            if isempty(ax) 
                ax = gca;
            end
            hold(ax, 'on');
            switch p.Results.Background
              case 'Original',
                im = imagesc(ax,this.PageImage);
              case 'Mono',
                im = imagesc(ax,this.PageImageMono);
              otherwise,
                error('Something wrong.');
            end
            if p.Results.ShowDilation
                im.AlphaData = 0.8;
                in = imagesc(ax,this.DilatedImage);
                in.AlphaData = 0.2;
            end
            set (ax,'YDir','reverse');
            colormap(ax,hot);
            for char_idx = 1:this.CharacterCount
                if ~p.Results.ShowOutliers && this.is_outlier(char_idx)
                    continue;
                end
                % Mark bounding box
                bbox = this.Characters(char_idx).Stats.BoundingBox;
                r = rectangle(ax,'Position',bbox);
                set(r,'EdgeColor','red');
                % Paint the face
                if this.Characters(char_idx).Ignore
                    set(r,'FaceColor',[0,0,1,.5]);                    
                elseif this.Characters(char_idx).IsShort
                    set(r,'FaceColor',[0,1,0,.5]);                    
                else
                    set(r,'FaceColor',[1,1,1,.2]);
                end
                % Show centroid
                if p.Results.ShowCentroids
                    s=scatter(ax,this.Centroids(:,1),this.Centroids(:,2),'o',...
                              'MarkerEdgeColor','red',...
                              'MarkerFaceColor','red',...
                              'MarkerFaceAlpha',0.3,...                      
                              'MarkerEdgeAlpha',0.5);
                end
            end

            this.draw_boundary(ax,'ShowVertical',p.Results.ShowVertical,...
                               'ShowHorizontal',p.Results.ShowHorizontal,...
                               'EraseVerticalLines',p.Results.EraseVerticalLines);
            %drawnow(ax);
            hold(ax, 'off');
        end

        function show_short_chars_img(this,varargin)
        % SHORT_CHARS_IMG shows short characters, which may be parts
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));            
            addParameter(p, 'ShowBoundingBoxes', true, @(x)islogical(x));            
            parse(p, this,varargin{:});

            imagesc(this.PageImageMono);
            set (gca,'YDir','reverse');
            colormap(hot);

            for char_idx = 1:this.CharacterCount
                if ~p.Results.ShowOutliers && this.is_outlier(char_idx)
                    continue;
                end
                % Mark bounding box
                bbox = this.Characters(char_idx).Stats.BoundingBox;
                r = rectangle('Position',bbox);
                %set(r,'EdgeColor','red');
                % Paint the face if 
                if this.Characters(char_idx).IsShort
                    set(r,'EdgeColor','red');
                    set(r,'FaceColor',[0,1,0,.5]);                    
                else
                    set(r,'FaceColor',[0,0,0,1]);
                end
            end

            if p.Results.ShowBoundingBoxes
                this.draw_bounding_boxes('ShowOutliers',p.Results.ShowOutliers);
            end

        end

        function show_columns(this,varargin)
        % SHOW_COLUMNS shows column assignment
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));            
            parse(p, this,varargin{:});

            imagesc(this.PageImage);
            set (gca,'YDir','reverse');
            colormap(jet);
            map = colormap;
            for char_idx = 1:this.CharacterCount
                if ~p.Results.ShowOutliers && this.is_outlier(char_idx)
                    continue;
                end
                % Mark bounding box
                bbox = this.Characters(char_idx).Stats.BoundingBox;
                r = rectangle('Position',bbox);
                %set(r,'EdgeColor','red');
                % Paint the face if 
                % if this.Characters(char_idx).IsShort
                %     set(r,'FaceColor',[0,1,0,.5]);                    
                % else
                %     set(r,'FaceColor',[0,0,0,1]);
                % end
                col = this.Columns(char_idx);
                col_mod = rem(17*col, size(map,1));
                set(r, 'EdgeColor', [map(col_mod, :),0.5],'LineWidth',3);
            end

        end

        function show_rows(this,varargin)
        % SHOW_ROWS shows row assignment
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));            
            parse(p, this,varargin{:});

            imagesc(this.PageImage);
            set (gca,'YDir','reverse');
            colormap(jet);
            map = colormap;
            for char_idx = 1:this.CharacterCount
                if ~p.Results.ShowOutliers && this.is_outlier(char_idx)
                    continue;
                end
                % Mark bounding box
                bbox = this.Characters(char_idx).Stats.BoundingBox;
                r = rectangle('Position',bbox);
                %set(r,'EdgeColor','red');
                % Paint the face if 
                % if this.Characters(char_idx).IsShort
                %     set(r,'FaceColor',[0,1,0,.5]);                    
                % else
                %     set(r,'FaceColor',[0,0,0,1]);
                % end
                row = this.Rows(char_idx);
                row_mod = rem(11*row, size(map,1));
                set(r, 'EdgeColor', [map(row_mod, :),0.5],'LineWidth',3);
            end
        end


        function show_centroids(this, varargin)
        % SHOW_CENTROIDS shows the centroid of each character
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));            
            addParameter(p, 'ShowColumns', true, @(x)islogical(x));            
            addParameter(p, 'ShowRows', false, @(x)islogical(x));            
            addParameter(p, 'ShowBoundingBoxes', true, @(x)islogical(x));
            parse(p, this,varargin{:});

            clf;
            colormap(hot);
            set (gca,'YDir','reverse');            

            hold on;
            im = imagesc(this.PageImage);
            im.AlphaData = 0.5;

            if p.Results.ShowBoundingBoxes
                this.draw_bounding_boxes('ShowOutliers',p.Results.ShowOutliers);
            end

            if p.Results.ShowColumns
                for col = 1:this.ColumnCount
                    c = this.Centroids(this.Columns == col,:);
                    c = sortrows(c,2);
                    in = plot(c(:,1),c(:,2),'LineWidth',2);
                end
            end

            if p.Results.ShowRows
                for row = 1:this.RowCount
                    c = this.Centroids(this.Rows == row,:);
                    c = sortrows(c,1);
                    in = plot(c(:,1),c(:,2),'LineWidth',2);
                end
            end
            s=scatter(this.Centroids(:,1),this.Centroids(:,2),...
                      'Marker', 'o',...
                      'MarkerEdgeColor','red',...
                      'MarkerFaceColor','red',...
                      'MarkerFaceAlpha',0.3,...                      
                      'MarkerEdgeAlpha',0.5);
            drawnow;
            hold off;
        end

        function show_column_centers(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));            
            addParameter(p, 'ShowBoundingBoxes', true, @(x)islogical(x));
            parse(p, this,varargin{:});

            clf;
            colormap(hot);
            set (gca,'YDir','reverse');            
            hold on;
            im = imagesc(this.PageImage);
            im.AlphaData = 0.5;

            if p.Results.ShowBoundingBoxes
                this.draw_bounding_boxes('ShowOutliers', ...
                                         p.Results.ShowOutliers);
            end

            for col = 1:this.ColumnCount
                c = this.ColumnCenters(col);
                line([c;c], [0;this.Height],'Color','magenta','LineWidth',2);
            end
            drawnow;
            hold off;
        end

        function Columns = get.Columns(this)
            N = this.CharacterCount;
            Columns = zeros(N,1);
            if N == 0
                return;
            end
            x = this.Centroids(:,1);
            % Sort centroids by x
            % For Traditional Chinese, right-to-left
            [x_sorted,I] = sort(x,'descend');  
            min_x = x_sorted(end)+1000;
            col = 1;
            for idx=1:numel(x)
                if ~this.is_outlier(I(idx))
                    if x_sorted(idx) <  min_x - this.opts.ColumnDistThreshold
                        col = col + 1;
                    end
                    min_x = x_sorted(idx);
                end
                Columns(I(idx)) = col;
            end
        end

        function Rows = get.Rows(this)
            switch this.Binding.Side
              case 'Left',
                binding_col = this.ColumnCount;
              case 'Right',
                binding_col = 1;
              otherwise,
                binding_col = 0;
            end
            Rows = zeros(this.CharacterCount,1);
            % Sort centroids by x
            y = this.Centroids(:,2);
            [y_sorted,I] = sort(y,'ascend');  % For traditional chinese, right-to-left
            max_y = 0;
            row = 1;
            for idx = 1:numel(y)
                if ~this.is_outlier(I(idx)) 
                    col = this.Columns(I(idx));
                    if ( col ~= binding_col ) && ...
                                ( y_sorted(idx) >  max_y + this.opts.RowDistThreshold ) 
                        row = row + 1;
                        max_y = y_sorted(idx);
                    end
                end
                Rows(I(idx)) = row;
            end
        end

        function  HorizontalBoundary = get.HorizontalBoundary(this)
        % HORIZONTAL_BOUNDARY - Find top and bottom
            se1 = strel('line',100,0);
            se2 = strel('line',10,90);
            BW = this.PageImageMono;
            % First slightly thicken in the vertical direction
            BW = imdilate(BW,se2);
            % Then significantly erode in the horizontal direction
            BW = imerode(BW, se1);
            % Dilate in the horizontal direction equally to erosion
            BW = imdilate(BW, se1);
            % Erode slightly in the vertical direction
            BW = imerode(BW, se2);
            HorizontalBoundary = BW;
       end

        function  BW = VerticalBoundary(this, varargin)
        % VERTICAL_BOUNDARY - Find left and right boundary
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addParameter(p, 'EraseVerticalLines', false, @(x)islogical(x));
            parse(p, this,varargin{:});
            % Find left and right
            se1 = strel('line',80,90);
            se2 = strel('line',20,0);
            BW = this.PageImageMono;
            % Dilate slightly in horizontal direction
            BW = imdilate(BW, se2);
            % Erode significantly in vertical direction
            BW = imerode(BW, se1);
            % Dilate by the amount of erosion
            BW = imdilate(BW, se1);
            % Erode by nearly the amount of original dilation
            if p.Results.EraseVerticalLines
                se3 = strel('line',25,0);            
            else
                se3 = strel('line',15,0);            
            end
            BW = imerode(BW, se3);
        end

        function  Boundary = get.Boundary(this)
            Boundary = this.HorizontalBoundary | this.VerticalBoundary;
        end


        function show_boundary(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));
            addParameter(p, 'ShowText', true, @(x)islogical(x));
            addParameter(p, 'ShowHorizontal', true, @(x)islogical(x));
            addParameter(p, 'ShowVertical', true, @(x)islogical(x));
            addParameter(p, 'ShowBoundingBoxes', true, @(x)islogical(x));
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));
            addParameter(p, 'EraseVerticalLines', true, @(x)islogical(x));
            parse(p, this,varargin{:});

            
            hold on;

            if p.Results.ShowText
                im = imagesc(this.PageImage);
                im.AlphaData = 0.5;
            end

            if p.Results.ShowBoundingBoxes
                this.draw_bounding_boxes('ShowOutliers',p.Results.ShowOutliers);
            end

            this.draw_boundary(varargin{:});
            colormap(hot);
            set (gca,'YDir','reverse');
            drawnow;
            hold off;
        end

        function draw_bounding_boxes(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));
            addParameter(p, 'ShowOutliers', false, @(x)islogical(x));
            addParameter(p, 'CharacterIndices', 1:this.CharacterCount, @(x)isnumeric(x));
            parse(p, this,varargin{:});

            for char_idx = p.Results.CharacterIndices
                if ~p.Results.ShowOutliers && this.is_outlier(char_idx)
                    continue;
                end
                % Mark bounding box
                bbox = this.Characters(char_idx).Stats.BoundingBox;
                r = rectangle('Position',bbox);
                set(r,'EdgeColor','red');
                % Paint the face if 
                if this.Characters(char_idx).Ignore
                    set(r,'FaceColor',[0,0,1,.5]);                                        
                elseif this.Characters(char_idx).IsShort
                    set(r,'FaceColor',[0,1,0,.5]);                    
                else
                    set(r,'FaceColor',[1,1,1,.2]);
                end
            end
        end


        function [T,R] = VerticalLines(this,varargin)
        % VERTICALLINES - returns parameters of vertical lines (up to 1)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));
            addParameter(p, 'NumberOfLines', 1, @(x)isscalar(x));
            parse(p, this,varargin{:});

            nhood_size = [199,199];                   % Suppression neighborhood size
            npeaks = p.Results.NumberOfLines;
            BW = this.VerticalBoundary;
            Theta = linspace(-10,10,200);
            [H,T,R] = hough(BW,'Theta',Theta);
            P = houghpeaks(H,npeaks, 'NHoodSize',nhood_size);
            T = T(P(:,2))';
            R = R(P(:,1))';
        end

        function show_vertical_lines(this,varargin)
        % SHOW_VERTICAL_LINE - show page boundary (non-binding)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));
            addParameter(p, 'NumberOfLines', 1, @(x)isscalar(x));
            parse(p, this, varargin{:});

            set(gca,'YDir','reverse');
            hold on;
            im = image(255*this.PageImageMono);
            im.AlphaData = 0.2;
            [T,R] = this.VerticalLines('NumberOfLines', p.Results.NumberOfLines);
            % The equation of the line is R=cos(T)*x+sin(T)*y
            % where T is small, thus cos(T)~=0. Hence, x = (R-sin(T)*y)/cos(T)
            for j=1:size(T,1)
                t = T(j)./90;
                r = R(j);
                y = 1:size(this.PageImageMono,1);
                x = (r-sin(t).*y)./cos(t);
                plot(x,y,'Color','red','LineWidth',3);
            end
            colormap(hot);
            title(sprintf('Theta: %6.3f ',T));
            drawnow;
            hold off;
        end

        function [T,R] = HorizontalLines(this)
        % HORIZONTALLINES - returns parameters of top and bottom lines
            nhood_size = [99,99];                   % Suppression neighborhood size
            npeaks = 2;
            BW = this.HorizontalBoundary';
            Theta = linspace(-10,10,200);
            [H,T,R] = hough(BW,'Theta',Theta);
            P = houghpeaks(H,npeaks, 'NHoodSize',nhood_size);
            T = T(P(:,2))';
            R = R(P(:,1))';
        end

        function show_horizontal_lines(this)
        % SHOW_VERTICAL_LINE - show page boundary (non-binding)
            set(gca,'YDir','reverse');
            hold on;
            im = image(255*this.PageImageMono);
            im.AlphaData = 0.2;
            [T,R] = this.HorizontalLines;
            % The equation of the line is R=cos(T)*x+sin(T)*y
            % where T is small, thus cos(T)~=0. Hence, x = (R-sin(T)*y)/cos(T)
            for j = 1:size(T,1)
                t = T(j)./90;
                r = R(j);
                y = 1:size(this.PageImageMono',1);
                x = (r-sin(t).*y)./cos(t);
                plot(y,x,'Color','red','LineWidth',3);
            end
            title(sprintf('Theta(degree): %.3f',T));
            colormap(hot);
            drawnow;
            hold off;
        end

        function Binding = get.Binding(this) 
        % BINDINGSIDE - returns the side of the binding
            [T,R] = this.VerticalLines;
            % The equation of the line is R=cos(T)*x+sin(T)*y
            % where T is small, thus cos(T)~=0. Hence, x = (R-sin(T)*y)/cos(T)
            y = this.Height/2;          % Half page height
            t = T./90;
            x = (R-sin(t)*y)/cos(t);
            if x < this.Width/4
                side='Right';
            elseif x > 3*this.Width/4
                side = 'Left';
            else
                side = [];       % Unknown
            end
            Binding = struct('Side',side,'X',x);
        end

        function draw_boundary(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));
            addOptional(p, 'Axes', [], @axes_test_fun);
            addParameter(p, 'ShowHorizontal', true, @(x)islogical(x));
            addParameter(p, 'ShowVertical', true, @(x)islogical(x));
            addParameter(p, 'EraseVerticalLines', true, @(x)islogical(x));

            parse(p, this,varargin{:});
            ax = p.Results.Axes;
            if isempty(ax)
                ax = gca;
            end

            BW = zeros(this.Size);

            if p.Results.ShowHorizontal
                BW = BW | this.HorizontalBoundary;
            end
            if p.Results.ShowVertical
                BW = BW | this.VerticalBoundary('EraseVerticalLines',...
                                                p.Results.EraseVerticalLines);
            end
            im = imagesc(ax,~BW);
            im.AlphaData = 0.5;            
        end

        function MergeCharacters = get.MergeCharacters(this)
            mc_count = 0;
            MergeCharacters = [];
            for col=1:this.ColumnCount
                chars = find( this.Columns == col );
                c = this.Centroids(chars,:);
                [c_sorted, I] = sortrows(c,2);
                sorted_chars = chars(I);
                for i = 1:numel(sorted_chars)
                    char_idx = sorted_chars(i);
                    if this.Characters(char_idx).IsShort
                        % Get neighbors
                        nb=[];
                        j=1;
                        if i > 1 
                            nb(j).row = i-1;
                            nb(j).idx = sorted_chars(i-1);
                            j = j+1;
                        end
                        if i < numel(sorted_chars)
                            nb(j).row = i+1;
                            nb(j).idx = sorted_chars(i+1);
                        end
                        if isempty(nb)
                            continue;
                        end
                        ci = [nb.idx];
                        mc_count = mc_count + 1;
                        MergeCharacters(mc_count).Col = col;
                        MergeCharacters(mc_count).Row = i;
                        MergeCharacters(mc_count).Idx = char_idx;
                        MergeCharacters(mc_count).MergedWith = nb;
                    end
                end
            end
        end

        function show_merge_characters(this)
            im = imagesc(this.PageImage);
            im.AlphaData = 0.5;
            for i=1:numel(this.MergeCharacters)
                nb = this.MergeCharacters(i).MergedWith;
                ci = [nb.idx];
                char_idx = this.MergeCharacters(i).Idx;
                this.draw_bounding_boxes('CharacterIndices',[ci,char_idx]);
            end
        end

        function do_merge_characters_all(this)
        %DO_MERGE_CHARACTERS_ALL - merge character parts into characters
        %  THIS = DO_MERGE_CHARACTERS_ALL(THIS) processes all 
        %  characters eligible for merging and does the merging,
        %  using a rule-based system:
        %  - a short character between two tall ones is merged
        %    with the nearby tall character
        %  - a short character between two short ones absorbs both
        %    of them, forming one (taller) character
        %  - a short character followed by another short character
        %    is merged with this character
        % 
            bh = waitbar(0,'Merging character bounding boxes...');
            do_merge_all_rule_sss(this);
            waitbar(1/3,bh);
            do_merge_all_rule_tst(this);            
            waitbar(2/3,bh);
            do_merge_all_rule_xss(this);
            waitbar(3/3,bh);
            close(bh);
        end

        function update_image_scan(this)
            I1 = 255 - this.PageImage; 
            this.PageImageMono = im2bw(I1,this.opts.BinThreshold);
            this.DilatedImage = imdilate(this.PageImageMono, this.DilationSE);

            stats = regionprops(this.DilatedImage,...
                                'BoundingBox',...
                                'MajorAxisLength',...
                                'MinorAxisLength',...
                                'Orientation',...
                                'Image',...
                                'Centroid');
            N = numel(stats);
            char_count = 0;
            for n=1:N
                is_outlier = false;
                if PageScan.filter_out(stats(n))
                    is_outlier = true;
                end
                if ~this.opts.KeepOutliers && is_outlier
                    continue;
                end

                J = zeros(size(this.PageImageMono));
                bbox = stats(n).BoundingBox;

                x1 = bbox(1); y1 = bbox(2); x2 = bbox(1) + bbox(3); y2 = bbox(2) + bbox(4);

                sz = size(this.PageImageMono);

                x1 = round( max(1,x1) ); x2 = round( min(x2, sz(2)));
                y1 = round( max(1,y1) ); y2 = round( min(y2, sz(1)));

                K = I1( y1:y2, x1:x2 );
                BW = this.PageImageMono( y1 : y2, x1 : x2 );

                % Save old width and height
                [h1,w1] = size(BW);
                [BW,rect] = imautocrop(BW);

                % New width and height
                [h2,w2] = size(BW);

                s = stats(n);
                % Adjust bounding box.  This makes a tight box around cropped character
                bbox1 = [bbox(1) + (rect(1)-0.5),...
                         bbox(2) + (rect(2)-0.5), ...
                         bbox(3)-(w1-w2)+1,...
                         bbox(4)-(h1-h2)+1];
                s.BoundingBox = bbox1;

                if this.filter_out_image(BW)
                    is_outlier = true;
                end

                if ~this.opts.KeepOutliers && is_outlier
                    continue;
                end
                char_count = char_count + 1;

                %disp(sprintf('Recording object %d as character %d', n, char_count));
                this.Characters(char_count).Stats = s;
                this.Characters(char_count).Position = [x1,y1,x2,y2];
                this.Characters(char_count).CroppedMonoImage = BW;
                this.Characters(char_count).AltImage = K; % Carved out image
                this.Characters(char_count).IsShort = bbox(4) < this.opts.ShortHeightThreshold;
                this.Characters(char_count).IsOutlier = is_outlier;
                this.Characters(char_count).Ignore = false;
            end
            % If there are no characters, we create an empty array to 
            % avoid exceptional handling when the page is empty
            if isempty(this.Characters)
                this.Characters = struct('Stats',{},'Position',{},...
                                         'CroppedMonoImage',{},...
                                         'AltImage',{},'IsShort',{}, ...
                                         'IsOutlier',{},'Ignore',{});
            end
        end

    end

    methods(Access = private)

        function scan_image(this, img)
        % SCAN_IMAGE - process image
            if nargin > 0
                this.PageImage = img;
            end
            update_image_scan;
        end

        function do_merge_all_rule_sss(this)
        %DO_MERGE_ALL_RULE_SSS - merge three short chars in a row
            disp('Merging by rule short-short-short...');
            for i=1:numel(this.MergeCharacters)
                nb = this.MergeCharacters(i).MergedWith;
                ci = [nb.idx];
                char_idx = this.MergeCharacters(i).Idx;
                c0 = this.Characters(char_idx);

                if c0.Ignore
                    continue;
                end

                % Two neighbors
                c = this.Characters(ci);

                if all([c.IsShort])
                    % All neighbors are short. If close enough, merge both 
                    d = arrayfun(@(x)bbox_vert_dist(x.Stats.BoundingBox, c0.Stats.BoundingBox),c);
                    e = arrayfun(@(x)bbox_hor_dist(x.Stats.BoundingBox, c0.Stats.BoundingBox),c);

                    % Note that the usual MergeThreshold is doubled here, as two short
                    % characters are typically further apart (e.g. 'two').
                    if all(d < 2*this.opts.MergeThreshold) && all(e == 0) && ~any([c.Ignore])
                        disp(sprintf('\tMerging character %d', char_idx));
                        arrayfun(@(x)this.do_merge_characters(char_idx,x), ...
                                 ci);
                    end
                end
            end
        end

        function do_merge_all_rule_tst(this)
        %DO_MERGE_ALL_RULE_TST - merge short char between two tall ones
            disp('Merging by rule tall-short-tall...');
            for i=1:numel(this.MergeCharacters)
                nb = this.MergeCharacters(i).MergedWith;
                ci = [nb.idx];
                char_idx = this.MergeCharacters(i).Idx;
                c0 = this.Characters(char_idx);

                if c0.Ignore
                    continue;
                end

                % These are the neighbor characters, 1 or 2.
                c = this.Characters(ci);

                if ~any([c.IsShort])
                    % All neightbors are tall, find the closer, and if close enough, merge.
                    d = arrayfun(@(x)bbox_vert_dist(x.Stats.BoundingBox, c0.Stats.BoundingBox),c);
                    e = arrayfun(@(x)bbox_hor_dist(x.Stats.BoundingBox, c0.Stats.BoundingBox),c);

                    [d,j] = min(d);
                    %if e(j) == 0 && ~c(j).Ignore
                    if ~c(j).Ignore                            
                        if d < this.opts.MergeThreshold
                            disp(sprintf('\tMerging character %d', char_idx));
                            this.do_merge_characters(ci(j), char_idx);
                        elseif ~c0.Ignore
                            % Enlarge the bounding box; this is necessary
                            % as OCR engine tends to be confused by the
                            % very short character, like 'one' (bar)
                            s = c0.Stats;
                            bbox = s.BoundingBox;
                            d1 = min(max(d - this.opts.MinVertGap, 0),...
                                     0.5*this.opts.MaxCharHeight);
                            if d1 > 0 
                                bbox1 = [bbox(1), bbox(2) - d1,...
                                         bbox(3),...
                                         bbox(4) + 2*d1
                                        ];
                                disp(sprintf('\tEnlarging bbox of character %d', char_idx));
                                s.BoundingBox = bbox1;
                                this.Characters(char_idx).Stats = s;
                            end
                        end
                    end
                end
            end
        end

        function do_merge_all_rule_xss(this)
        %DO_MERGE_ALL_RULE_XSS - merge two short chars
            disp('Merging by ?-short-short...');
            for i=1:numel(this.MergeCharacters)
                nb = this.MergeCharacters(i).MergedWith;
                ci = [nb.idx];
                char_idx = this.MergeCharacters(i).Idx;
                c0 = this.Characters(char_idx);

                if c0.Ignore
                    continue;
                end

                if numel(ci) == 2
                    % Two neighbors
                    c = this.Characters(ci);

                    if c(2).IsShort && ~c(2).Ignore
                        % One neighbor is short, the other is long
                        % Find the short one and merge
                        d = bbox_vert_dist(c(2).Stats.BoundingBox, ...
                                           c0.Stats.BoundingBox);
                        
                        e = bbox_hor_dist(c(2).Stats.BoundingBox,...
                                          c0.Stats.BoundingBox);

                        if d < 2*this.opts.MergeThreshold && e == 0
                            disp(sprintf('\tMerging character %d', char_idx));
                            this.do_merge_characters(char_idx, ci(2));
                        end
                    end
                end
            end
        end

        function do_merge_characters(this, idx1, idx2)
        % DO_MERGE_CHARACTERS - Merge bounding boxes
            this.Characters(idx1).Stats.BoundingBox = ...
                bbox_union(...
                    this.Characters(idx1).Stats.BoundingBox,...
                    this.Characters(idx2).Stats.BoundingBox);
            this.Characters(idx2).Ignore = true;
        end



        function updateExternalOcrResultsCache(this)
        % UPDATEEXTERNALOCRRESULTSCACHE - runs externsl OCR
            r = TesseractRecognizer('Language','chi_tra','PageSegmentationMode',10);
            ignored=[this.Characters.Ignore];
            this.ExternalOcrResultsCache = struct('Text',[]);
            bh = waitbar(0,'Running external OCR...');

            for i=1:this.CharacterCount
                waitbar(i/this.CharacterCount,bh);
                if ignored(i)
                    continue;
                end
                I = this.Characters(i).CroppedMonoImage;
                I = padarray(I,[10 10],0,'both');
                this.ExternalOcrResultsCache(i).Text = fix_tess_output(r.recognize(~I));
            end

            close(bh);
        end

        function updateMexOcrResultsCache(this)
        % UPDATEEXTERNALOCRRESULTSCACHE - runs externsl OCR
            ignored=[this.Characters.Ignore];
            this.MexOcrResultsCache = struct('Text',[]);

            I = 255*(~this.PageImageMono);
            %I = this.PageImage;
            %I = rgb2gray(I);
            J = uint8(fliplr(I));

            x1 = this.ROI(:,1);
            y1 = this.ROI(:,2);
            w = this.ROI(:,3);
            h = this.ROI(:,4);
            x2 = x1 + w;
            y2 = y1 + h;

            [H, W] = size(I);

            % Enlarge boxes around characters
            dw = 5;
            dh = 5;
            x1 = max(0, x1 - dw);
            y1 = max(0, y1 - dh);
            x2 = min(W, x2 + dw);
            y2 = min(H, y2 + dh);


            ROI = [y1, W - x2, y2 - y1, x2 - x1];
            out = tessWrapperWithConfidence(J, 'chi_tra_vert','/usr/local/share/tessdata',...
                                            ROI);
            
            for i=1:this.CharacterCount
                if isempty(out(i).Symbol) 
                    this.MexOcrResultsCache(i).Text = '?';
                else
                    this.MexOcrResultsCache(i).Text = out(i).Symbol;
                end
            end
        end


    end


    methods(Access=private)

        function rv = is_outlier(this, char_idx)
        % IS_OUTLIER returns true if character is outlier
            rv = this.Characters(char_idx).IsOutlier;
        end

        function rv = is_short(this, char_idx)
        % IS_SHORT returns true if character is short
            rv = this.Characters(char_idx).IsShort;
        end

        function rv = filter_out_image(this, K)
        % FILTER_OUT_IMAGE - filter out base
            rv=false;
            % Filter out tall and narrow images
            if size(K,1) > this.opts.MaxCharWidth || size(K,2) < this.opts.MinCharHeight;
                rv=true;
            end
        end

    end

    methods(Static)
        function rv=filter_out(stat)
        % FILTER_OUT - filter out object based on stat
            rv=false;
            % Filter out tall, nearly vertical objects
            if stat.MinorAxisLength ./ stat.MajorAxisLength < 2e-1 && abs(stat.Orientation-90)<5
                rv=true;
            end
        end


    end
end


%================================================================
%
% Box operations
% NOTE: They could be static methods in PageScan
% but just as well can be ordinary function in the class file.
% We chose to make them ordinary functions due to their
% general nature.
%
%================================================================

function [x,y,w,h] = dbox(bbox)
% DBOX - extract components of bbox
    x = bbox(1);
    y = bbox(2);
    w = bbox(3);
    h = bbox(4);
end

function rv = bbox_union(bbox1, bbox2);
    [x1,y1,w1,h1] = dbox(bbox1);
    [x2,y2,w2,h2] = dbox(bbox2);            
    x = min(x1,x2);
    y = min(y1,y2);            
    x_max = max(x1+w1, x2+w2);
    y_max = max(y1+h1, y2+h2);            
    w = x_max-x;
    h = y_max-y;
    rv = [x,y,w,h];
end


function xrange = bbox_hor_range(bbox)
% BBOX_HOR_RANGE - horizontal range of BBOX
    [x,y,w,h] = dbox(bbox);
    xrange = [x,x+w];
end

function yrange = bbox_vert_range(bbox)
% BBOX_VERT_RANGE - vertical range of BBOX
    [x,y,w,h] = dbox(bbox);
    yrange = [y,y+h];
end

function D = bbox_hor_dist(bbox1, bbox2)
% BBOX_HOR_DIST - distance between BBOX1 and BBOX2 in horizontal direction
    D = interval_dist(bbox_hor_range(bbox1),...
                      bbox_hor_range(bbox2));
end

function D = bbox_vert_dist(bbox1, bbox2)
% BBOX_VERT_DIST - vertical distance between BBOX1 and BBOX2            
    D = interval_dist(bbox_vert_range(bbox1),...
                      bbox_vert_range(bbox2));
end


function D = interval_dist(a, b)
% INTERVAL_DIST - distance between intervals
    assert(a(1) < a(2));
    assert(b(1) < b(2));
    if a(2) < b(1) 
        D = b(1) - a(2);
    elseif a(1) > b(2)
        D = a(1) - b(2);
    else 
        D = 0;
    end
end

function fixedstr = fix_tess_output(str)
% FIX_TESS_OUTPUT - fixes Tesseract output to be a single character
%FIXEDSTR = FIX_TESS_OUTPUT(STR)
    if numel(str)==3
        fixedstr=str(1);
    else
        fixedstr='?';
    end
end


function rv = axes_test_fun(x)
% AXES_TEST_FUN - test of object is an axis, or empty
    rv = isempty(x) || ...
         isa(x,'matlab.graphics.axis.Axes') ||...
         isa(x,'matlab.ui.control.UIAxes');
end

