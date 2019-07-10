%
% NOTE: This is parallelized version of scanner.m
% It does not plot for speed.
% It runs the book in about 30 seconds
%
% This script scans through the pages of a book in Chinese and
% divides them into characters. 
% 
% Pages are asssumed to be images in directory PAGEDIR, with
% filename pattern PAGE_IMG_PATTERN.
%
% The characters are written in grayscale to directory CHARDIR.
% Additionally, monochromatic character images are placed in directory
% BW_CHARDIR.
%
% The algorithm is based on dilation and dividing the dilated
% image into regions. The structuring element should be picked
% to be large enough to connect parts within characters, and
% to be small enough to separate distinct characters.
% 
classdef PageScan
    properties
        DilationSE = strel('rectangle', [5,15]); % for imdilate
        Characters = struct('Position','Stats');
        PageImage = [];
        PageImageMono = [];
        DilatedImage = [];
        short_height_threshold = 30;
        column_dist_threshold = 60;
        row_dist_threshold = 40;        
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
    end

    methods
        function this = PageScan(filename, varargin)
            this = this.scanfile(filename,varargin{:});
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

        function ColumnCenters = get.ColumnCenters(this)
            ColumnCenters = zeros(this.ColumnCount, 1);
            for col=1:this.ColumnCount
                ColumnCenters(col) = mean(this.Centroids(this.Columns == col,1));
            end
        end

        function  HorizontalRanges = get.HorizontalRanges(this)
            fh = @(s)PageScan.bbox_hor_range(s.Stats.BoundingBox)';
            HorizontalRanges = cell2mat(arrayfun(fh,this.Characters,'UniformOutput',false))';
        end


        function show_marked_page_img(this,varargin)
        % MARKED_PAGEIMAGE shows page with character bounding boxes
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'Background', 'Original',...
                        @(x)any(validatestring(x,{'Original','Mono'})));
            addOptional(p, 'ShowCentroids', true, @(x)islogical(x));
            addOptional(p, 'ShowDilation', false, @(x)islogical(x));            
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));            
            parse(p, this,varargin{:});
            hold on;
            switch p.Results.Background
              case 'Original',
                im = imagesc(this.PageImage);
              case 'Mono',
                im = imagesc(this.PageImageMono),
              otherwise,
                error('Something wrong.');
            end
            if p.Results.ShowDilation
                im.AlphaData = 0.8;
                in = imagesc(this.DilatedImage);
                in.AlphaData = 0.2;
            end
            set (gca,'YDir','reverse');
            colormap(hot);
            for char_idx = 1:this.CharacterCount
                if ~p.Results.ShowOutliers && this.is_outlier(char_idx)
                    continue;
                end
                % Mark bounding box
                bbox = this.Characters(char_idx).Stats.BoundingBox;
                r = rectangle('Position',bbox);
                set(r,'EdgeColor','red');
                % Paint the face
                if this.Characters(char_idx).IsShort
                    set(r,'FaceColor',[0,1,0,.5]);                    
                else
                    set(r,'FaceColor',[1,1,1,.2]);
                end
                % Show centroid
                if p.Results.ShowCentroids
                    s=scatter(this.Centroids(:,1),this.Centroids(:,2),'o',...
                              'MarkerEdgeColor','red',...
                              'MarkerFaceColor','red',...
                              'MarkerFaceAlpha',0.3,...                      
                              'MarkerEdgeAlpha',0.5);
                end
            end
            hold off;
        end

        function show_short_chars_img(this,varargin)
        % SHORT_CHARS_IMG shows short characters, which may be parts
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));            
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

        end

        function show_columns(this,varargin)
        % SHOW_COLUMNS shows column assignment
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));            
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
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));            
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
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));            
            addOptional(p, 'ShowColumns', true, @(x)islogical(x));            
            addOptional(p, 'ShowRows', false, @(x)islogical(x));            
            addOptional(p, 'ShowBoundingBoxes', true, @(x)islogical(x));
            parse(p, this,varargin{:});

            clf;
            colormap(hot);
            set (gca,'YDir','reverse');            

            hold on;
            im = imagesc(this.PageImage);
            im.AlphaData = 0.5;

            if p.Results.ShowBoundingBoxes
                this.draw_bounding_boxes(varargin{:});
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
            hold off;
        end

        function show_column_centers(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));            
            addOptional(p, 'ShowBoundingBoxes', true, @(x)islogical(x));
            parse(p, this,varargin{:});

            clf;
            colormap(hot);
            set (gca,'YDir','reverse');            
            hold on;
            im = imagesc(this.PageImage);
            im.AlphaData = 0.5;

            this.draw_bounding_boxes(varargin{:});

            for col = 1:this.ColumnCount
                c = this.ColumnCenters(col);
                line([c;c], [0;this.Height],'Color','magenta','LineWidth',2);
            end
            hold off;
        end

        function Columns = get.Columns(this)
            Columns = zeros(this.CharacterCount,1);
            x = this.Centroids(:,1);
            % Sort centroids by x
            % For Traditional Chinese, right-to-left
            [x_sorted,I] = sort(x,'descend');  
            min_x = x_sorted(end)+1000;
            col = 1;
            for idx=1:numel(x)
                if ~this.is_outlier(I(idx))
                    if x_sorted(idx) <  min_x - this.column_dist_threshold
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
                    if ( col ~= binding_col ) && ( y_sorted(idx) >  max_y + this.row_dist_threshold ) 
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
            BW = imerode(BW,se2);
            HorizontalBoundary = BW;
       end

        function  BW = VerticalBoundary(this, varargin)
        % VERTICAL_BOUNDARY - Find left and right boundary
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'EraseVerticalLines', false, @(x)islogical(x));
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
            addOptional(p, 'ShowText', true, @(x)islogical(x));
            addOptional(p, 'ShowHorizontal', true, @(x)islogical(x));
            addOptional(p, 'ShowVertical', true, @(x)islogical(x));
            addOptional(p, 'ShowBoundingBoxes', true, @(x)islogical(x));
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));
            addOptional(p, 'EraseVerticalLines', true, @(x)islogical(x));
            parse(p, this,varargin{:});

            BW = zeros(this.Size);

            if p.Results.ShowHorizontal
                BW = BW | this.HorizontalBoundary;
            end
            if p.Results.ShowVertical
                BW = BW | this.VerticalBoundary('EraseVerticalLines',...
                                                p.Results.EraseVerticalLines);
            end

            hold on;

            if p.Results.ShowText
                im = imagesc(this.PageImage);
                im.AlphaData = 0.5;
            end

            if p.Results.ShowBoundingBoxes
                this.draw_bounding_boxes(varargin{:});
            end

            in = imagesc(~BW);
            in.AlphaData = 0.5;            
            colormap(hot);
            set (gca,'YDir','reverse');
            hold off;
        end

        function draw_bounding_boxes(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));
            addOptional(p, 'ShowOutliers', false, @(x)islogical(x));
            parse(p, this,varargin{:});

            for char_idx = 1:this.CharacterCount
                if ~p.Results.ShowOutliers && this.is_outlier(char_idx)
                    continue;
                end
                % Mark bounding box
                bbox = this.Characters(char_idx).Stats.BoundingBox;
                r = rectangle('Position',bbox);
                set(r,'EdgeColor','red');
                % Paint the face if 
                if this.Characters(char_idx).IsShort
                    set(r,'FaceColor',[0,1,0,.5]);                    
                else
                    set(r,'FaceColor',[1,1,1,.2]);
                end
            end
        end


        function [T,R] = VerticalLines(this)
        % VERTICALLINES - returns parameters of vertical lines (up to 1)
            nhood_size = [199,199];                   % Suppression neighborhood size
            npeaks = 1;
            BW = this.VerticalBoundary;
            Theta = linspace(-10,10,200);
            [H,T,R] = hough(BW,'Theta',Theta);
            P = houghpeaks(H,npeaks, 'NHoodSize',nhood_size);
            T = T(P(:,2))';
            R = R(P(:,1))';
        end

        function show_vertical_lines(this)
        % SHOW_VERTICAL_LINE - show page boundary (non-binding)
            set(gca,'YDir','reverse');
            hold on;
            im = image(255*this.PageImageMono);
            im.AlphaData = 0.2;
            [T,R] = this.VerticalLines;
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
            title(sprintf('Theta(degree): %.3f',T));
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
    end

    methods(Access = private)

        function this = scanfile(this,filename,varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'KeepOutliers', false, @(x)islogical(x));            
            parse(p, this,varargin{:});

            this.PageImage = imread(filename);
            I1 = 255 - this.PageImage; 
            this.PageImageMono = im2bw(I1);
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
                if ~p.Results.KeepOutliers && is_outlier
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
                BW = imautocrop(BW);

                if PageScan.filter_out_image(BW)
                    is_outlier = true;
                end

                if ~p.Results.KeepOutliers && is_outlier
                    continue;
                end
                char_count = char_count + 1;

                %disp(sprintf('Recording object %d as character %d', n, char_count));
                this.Characters(char_count).Stats = stats(n);
                this.Characters(char_count).Position = [x1,y1,x2,y2];
                this.Characters(char_count).CroppedMonoImage = BW;
                this.Characters(char_count).AltImage = K; % Carved out image
                this.Characters(char_count).IsShort = bbox(4) < this.short_height_threshold;
                this.Characters(char_count).IsOutlier = is_outlier;
            end
        end

        function rv = is_outlier(this, char_idx)
        % IS_OUTLIER returns true if character is outlier
            rv = this.Characters(char_idx).IsOutlier;
        end

        function rv = is_short(this, char_idx)
        % IS_SHORT returns true if character is short
            rv = this.Characters(char_idx).IsShort;
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

        function rv=filter_out_image(K)
        % FILTER_OUT_IMAGE - filter out base
            rv=false;
            % Filter out tall and narrow images
            if size(K,1) > 100 || size(K,2) < 10
                rv=true;
            end
        end

        function [x,y,w,h] = dbox(bbox)
        % DBOX - extract components of bbox
            x = bbox(1);
            y = bbox(2);
            w = bbox(3);
            h = bbox(4);
        end

        function xrange = bbox_hor_range(bbox)
        % BBOX_HOR_RANGE - horizontal range of BBOX
            [x,y,w,h] = PageScan.dbox(bbox);
            xrange = [x,x+w];
        end

        function D = interval_hor_dist(a, b)
        % INTERVAL_HOR_DIST - distance between intervals
            if a(2) < b(1) 
                D = b(1) - a(2);
            elseif a(1) > b(2)
                D = b(2) - a(1);
            else 
                D = 0;
            end
        end

        function D = bbox_dist(bbox1, bbox2)
        % BBOX_DIST - distance between BBOX1 and BBOX2
            D = PageScan.interval_hor_dist(PageScan.bbox_hor_range(bbox1),...
                                           PageScan.bbox_hor_range(bbox2));
        end
    end
end