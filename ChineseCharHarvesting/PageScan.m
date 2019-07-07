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
        StructuringElement = strel('rectangle', [9,15]); % for imdilate
        Characters = struct('Position','Stats');
        page_img = [];
        page_img_mono = [];
        dilated_img = [];
        short_height_threshold = 30;
    end

    properties(Dependent)
        CharacterCount;                 % Number of identified characters
        Centroids;               % Character centroids - CharacterCount-by-2
        HorizontalRanges;            % Horizontal extends of characters.
    end

    methods
        function CharacterCount = get.CharacterCount(this)
            CharacterCount = numel(this.Characters);
        end

        function Centroids = get.Centroids(this)
            fh = @(s)s.Stats.Centroid';
            Centroids = cell2mat(arrayfun(fh,this.Characters,'UniformOutput',false))';
        end

        function  HorizontalRanges = get.HorizontalRanges(this)
            fh = @(s)PageScan.bbox_hor_range(s.Stats.BoundingBox)';
            HorizontalRanges = cell2mat(arrayfun(fh,this.Characters,'UniformOutput',false))';
        end

        function this = scanfile(this,filename)
            this.page_img = imread(filename);
            I1 = 255 - this.page_img; 
            this.page_img_mono = im2bw(I1);
            this.dilated_img = imdilate(this.page_img_mono, this.StructuringElement);
            stats = regionprops(this.dilated_img,...
                                'BoundingBox',...
                                'MajorAxisLength',...
                                'MinorAxisLength',...
                                'Orientation',...
                                'Image',...
                                'Centroid');
            N = numel(stats);
            char_count = 0;
            for n=1:N
                if PageScan.filter_out(stats(n))
                    continue;
                end

                J = zeros(size(this.page_img_mono));
                bbox = stats(n).BoundingBox;
                x1 = bbox(1); y1 = bbox(2); x2 = bbox(1) + bbox(3); y2 = bbox(2) + bbox(4);
                sz = size(this.page_img_mono);
                x1 = round( max(1,x1) ); x2 = round( min(x2, sz(2)));
                y1 = round( max(1,y1) ); y2 = round( min(y2, sz(1)));

                K = I1( y1:y2, x1:x2 );
                BW = this.page_img_mono( y1 : y2, x1 : x2 );
                BW = imautocrop(BW);

                if PageScan.filter_out_image(BW)
                    continue
                end

                char_count = char_count + 1;

                %disp(sprintf('Recording object %d as character %d', n, char_count));
                this.Characters(char_count).Stats = stats(n);
                this.Characters(char_count).Position = [x1,y1,x2,y2];
                this.Characters(char_count).CroppedMonoImage = BW;
                this.Characters(char_count).AltImage = K; % Carved out image
                this.Characters(char_count).IsShort = bbox(4) < this.short_height_threshold;
            end
        end

        function show_marked_page_img(this,varargin)
        % MARKED_PAGE_IMG shows page with character bounding boxes
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'Background', 'Original',...
                        @(x)any(validatestring(x,{'Original','Mono'})));
            parse(p, this,varargin{:});
            switch p.Results.Background
              case 'Original',
                  imagesc(this.page_img);
              case 'Mono',
                  imagesc(this.page_img_mono),
              otherwise,
                error('Something wrong.');
            end
            colormap(hot);
            for char_idx = 1:this.CharacterCount
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

        function show_short_chars_img(this,varargin)
        % SHORT_CHARS_IMG shows short characters, which may be parts
            imagesc(this.page_img_mono);
            colormap(hot);
            for char_idx = 1:this.CharacterCount
                % Mark bounding box
                bbox = this.Characters(char_idx).BoundingBox;
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

        function show_centroids(this)
            clf;
            hold on;
            im = imagesc(this.page_img);
            im.AlphaData = 0.5;
            s=scatter(this.Centroids(:,1),this.Centroids(:,2),'o',...
                      'MarkerEdgeColor','red',...
                      'MarkerFaceColor','red',...
                      'MarkerFaceAlpha',0.3,...                      
                      'MarkerEdgeAlpha',0.5)
            hold off;
        end


        function [this,S]=cluster_centroids(this, varargin)
            p = inputParser;
            addRequired(p, 'this', @(x)isa(x,'PageScan'));            
            addOptional(p, 'Angle', 0, @(x)isscalar(x));
            parse(p, this, varargin{:});
            N = this.CharacterCount;
            D = zeros(N,N);                        
            
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