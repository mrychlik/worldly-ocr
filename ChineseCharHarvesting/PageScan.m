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
    properties(Constant)
        regprops = {};
    end
    properties
        se = strel('rectangle', [9,15]);
        char_count = [];
        chars = struct('Position','Stats');
        page_img = [];
        page_img_mono = [];
        dilated_img = [];
        short_height_threshold = 30;
    end

    methods
        function this = scanfile(this,filename)
            this.page_img = imread(filename);
            I1 = 255 - this.page_img; 
            this.page_img_mono = im2bw(I1);
            this.dilated_img = imdilate(this.page_img_mono, this.se);
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
                this.chars(char_count).Stats = stats(n);
                this.chars(char_count).Position = [x1,y1,x2,y2];
                this.chars(char_count).CroppedMonoImage = BW;
                this.chars(char_count).AltImage = K; % Carved out image
                this.chars(char_count).IsShort = bbox(4) < this.short_height_threshold;
            end
            this.char_count = char_count;
        end

        function marked_page_img(this,varargin)
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
            for char_idx = 1:this.char_count
                % Mark bounding box
                bbox = this.chars(char_idx).Stats.BoundingBox;
                r = rectangle('Position',bbox);
                set(r,'EdgeColor','red');
                % Paint the face if 
                if this.chars(char_idx).is_short
                    set(r,'FaceColor',[0,1,0,.5]);                    
                else
                    set(r,'FaceColor',[1,1,1,.2]);
                end
            end
        end

        function short_chars_img(this,varargin)
        % SHORT_CHARS_IMG shows short characters, which may be parts
            imagesc(this.page_img_mono);
            colormap(hot);
            for char_idx = 1:this.char_count
                % Mark bounding box
                bbox = this.chars(char_idx).BoundingBox;
                r = rectangle('Position',bbox);
                %set(r,'EdgeColor','red');
                % Paint the face if 
                if this.chars(char_idx).IsShort
                    set(r,'EdgeColor','red');
                    set(r,'FaceColor',[0,1,0,.5]);                    
                else
                    set(r,'FaceColor',[0,0,0,1]);
                end
            end

        end

        function this=cluster_centroids(this, angle)
            a = angle/180*pi;           % Convert to radians
            v = [cos(a),sin(a)];
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
    end
end