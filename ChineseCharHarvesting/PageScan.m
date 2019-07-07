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
        se=strel('rectangle',[9,15]);
        char_count = [];
        chars = struct('position',[]);
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
                b = stats(n).BoundingBox;
                x1 = b(1); y1 = b(2); x2 = b(1) + b(3); y2 = b(2) + b(4);
                sz = size(this.page_img_mono);
                x1 = round( max(1,x1) ); x2 = round( min(x2, sz(2)));
                y1 = round( max(1,y1) ); y2 = round( min(y2, sz(1)));

                K = I1( y1:y2, x1:x2 );
                BW = this.page_img_mono( y1 : y2, x1 : x2 );
                BW = imautocrop(BW);

                if PageScan.filter_image(BW)
                    continue
                end

                char_count = char_count + 1;

                %disp(sprintf('Recording object %d as character %d', n, char_count));
                this.chars(char_count).position = [x1,y1,x2,y2];
                this.chars(char_count).BW = BW;
                this.chars(char_count).Image = K;
                this.chars(char_count).stats = stats(n);
            end
            this.char_count = char_count;
        end

        function marked_page_img(this,varargin)
            p=inputParser;
            addRequired(p,'this',@(x)isa(x,'PageScan'));            
            addOptional(p,'Background','Original',...
                        @(x)any(validatestring(x,{'Original','Mono'})));
            parse(p,this,varargin{:});
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
                bbox = this.chars(char_idx).stats.BoundingBox;
                r = rectangle('Position',bbox);
                set(r,'EdgeColor','red');
                % Paint the face if 
                if bbox(4) < this.short_height_threshold
                    set(r,'FaceColor',[0,1,0,.5]);                    
                end
            end
        end

    end

    methods(Static)
        function rv=filter_out(stat)
            rv=false;
            % Filter out tall, nearly vertical objects
            if stat.MinorAxisLength ./ stat.MajorAxisLength < 2e-1 && abs(stat.Orientation-90)<5
                rv=true;
            end

        end

        function rv=filter_image(K)
            rv=false;
            % Filter out objects taller than 100 pixels and narrower than
            % 10 pixels
            if size(K,1) > 100 || size(K,2) < 10
                rv=true;
            end
        end
    end
end