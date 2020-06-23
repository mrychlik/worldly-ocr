classdef LineBreaker
%LINEBREAKER Breaks up an image into lines of text.
    properties
        BW;                             % The image to be broken up.
        LabeledLines;                   % Image labeled with lines.
        NumLines;                       % Number of lines detected.
        NumControlPoints = 20;          % Number of points in regression line.
        HorDistance = 40;               % x-distance to dilate by.
        VertDistance = 10;              % y-distance to dilate by.
        SigmaFactor = 1;            % Number of sigma to merge diacriticals.
        MinLineLength = 3;              % Min. line length to plot.
        MinRows = 7;                    % Min. number of rows in non-speckle.
        MinCols = 7;                    % Min. number of cols in non-speckle.
        PixelCounts;                    % Line pixel counts.
        PolyFit;                        % Polynomial fit structure.
        Degree = 1;                     % The degree of polynomial fit.
        Recognizer;
    end
    
    methods
        function this = LineBreaker(BW,psm,language)
        %LineBreaker Constructor
        %  THIS = LINEBREAKER(BW,PSM,LANGUAGE) constructs an instance
        %  which will hold an binary image BW and perform various
        %  methods on it. The optional argument PSM defines Tesseract
        %  'page segmentation mode' (default: 7). The modes are
        %  described in the documentation of class TesseractRecognizer.
            narginchk(1,3);
            if nargin < 2; psm = 7; end % Line page segmentation
            if nargin < 3; language = 'pus'; end % Pashto
            this.BW = BW;
            this.Recognizer = TesseractRecognizer(psm, language);
            this = despeckle(this);
            this = line_breaks_by_shift(this);
            this = fit_lines(this);
        end
    end

    methods(Access=private)
        function this = line_breaks_by_shift(this)
        % Break up an image into lines of text.
        % this.LabeledLines: this is the most important output of this
        % fucntion. It assigend the line number to the each pixel (connected objects)
            se1 = strel('line',this.HorDistance,0);
            BW1 = imdilate(this.BW,se1);
            [L,N] = bwlabel(BW1,4);
            YMedians = zeros([1,N]);
            for n=1:N   %N= total number of connected objects in dilated figure
                [Y,X,~] = find(L==n);
                YMedians(n) = median(Y);   %finding the median of the connected object n
            end
            % Sort lines by mean value of the y-coordinate
            [~,I] = sort(YMedians, 'descend');     
            J(I) = 1:N;                 % Invert permutation
            
            [S,M] = bwlabel(this.BW, 4);   % Find objects in the original image
            this.LabeledLines = zeros(size(this.BW));
            this.PixelCounts = zeros([1,N]);
            for m=1:M   %M= total number of connected objects in original figure
                [r,c] = find(S==m, 1, 'first');
                l = L(r,c);    % connected object m in orignal figure, is the connected object l in dilated figure
                lab = J(l);    % the connected object l in dilated figure is in line J(l) or lab
                U = S==m;      % selecting all connected object m in orignal figure
                this.LabeledLines(U) = lab;   % switching the number of connected object, m, in orignal figure with number of the line, lab
                this.PixelCounts(lab) = sum(sum(U));  % total number of the pixel are involved in this porcess
            end
            this.NumLines = N;
        end
    end

    methods
        function this = fit_lines(this)
        % Compute regression lines from lines of text
            this.PolyFit = cell(1,this.NumLines);
            for l=this.NumLines:-1:1
                this = fit_line_to_label(this, l);
            end
        end

        function this = fit_line_to_label(this,l)
            J = this.LabeledLines==l;
            [y,x] = find(J);
            assert(length(x) > 1)
            [p,S,mu] = polyfit(x,y,this.Degree);
            xhat = (x-mu(1))/mu(2); % mu(1) is mean(x), and mu(2) is std(x)
            [yhat,delta] = polyval(p,xhat,S);
            [x_low,x_high] = bounds(x);
            [y_low,y_high] = bounds(y);

            % Record the fit
            f = struct();
            f.p = p;
            f.S = S;
            f.mu = mu;
            f.x_low = x_low;
            f.x_high = x_high; 
            f.y_low = y_low;
            f.y_high = y_high;             
            f.yhat = yhat;
            f.delta = delta;
            [lo,hi]= bounds(y-yhat);
            f.bounds = [lo,hi];

            this.PolyFit{l} = f;
        end


        function this = despeckle(this)
            [S,M] = bwlabel(this.BW, 4);
            for l=1:M
                [y,x] = find(S==l);
                if length(y) < this.MinRows || length(x) < this.MinCols
                    S(S==l)=0;
                end
            end
            this.BW(S==0)=0;
        end

        function this = relabel(this)
        % Relabel image to a contiguous set of labels
            idx = find(this.PixelCounts>0); %New labels
            N = length(idx);
            map = this.PixelCounts;
            map(idx) = 1:N;
            mask = this.LabeledLines>0;
            this.LabeledLines(mask) = map(this.LabeledLines(mask));
            this.PixelCounts = this.PixelCounts(idx);
            this.NumLines = N;
            this = fit_lines(this);
        end

        
        function [lng, shrt] = detect_short_lines(this)
        % Divide lines into long and short
            x_low = cellfun(@(u)u.x_low, this.PolyFit);
            x_high = cellfun(@(u)u.x_high, this.PolyFit);
            x_dist = x_high-x_low;
            y_low = cellfun(@(u)u.y_low, this.PolyFit);
            y_high = cellfun(@(u)u.y_high, this.PolyFit);
            y_dist = y_high-y_low;
            
            
            shrt = find(x_dist < 2*this.HorDistance | y_dist  < 2*this.VertDistance);
            lng = find(x_dist >= 2*this.HorDistance & y_dist >= 2*this.VertDistance);
        end

        function lines = long_neighbors(this, s)
        % Find the long lines above and below of s
            [lng,~] = detect_short_lines(this);
            ys = this.PolyFit{s}.p(2);
            yl = zeros(size(lng));
            yl = cellfun(@(u)u.p(2), {this.PolyFit{lng}});
            lng_above = find(yl < ys, 1,'first');
            lng_below = find(yl > ys,1,'last');
            lines = lng([lng_above, lng_below]);
        end


        function this = merge_short_lines(this)
        %MERGE_SHORT_LINES Merges short lines with nearby long lines.
        % THIS = MERGE_SHORT_LINES(THIS) divides lines into short and
        % long, and it tries to merge each short line into one of the
        % closest two long lines of text.
            [~,shrt] = detect_short_lines(this);
            for s=shrt
                nb = long_neighbors(this, s);
                [y,x] = find(this.LabeledLines == s);
                for l = nb
                    f = this.PolyFit{l};
                    xhat = (x-f.mu(1)) / f.mu(2);
                    [yhat, delta] = polyval(f.p, xhat, f.S);
                    w = this.SigmaFactor;
                    if all( y < yhat + f.bounds(2) + w*delta) && ...
                            all( y > yhat + f.bounds(1) - w*delta)
                        fprintf('Merging short line %d with long line %d\n',s,l);
                        this.LabeledLines(this.LabeledLines==s)=l;
                        this.PixelCounts(l) = this.PixelCounts(l) + ...
                            this.PixelCounts(s);
                        this.PixelCounts(s) = 0;
                        break;
                    end
                end
            end
            this = relabel(this);
        end


        function plot_lines(this,lines)
        %PLOT_LINES Plot regression lines of text lines.
        %  PLOT_LINES(THIS,LINES)  plots regression lines on top of the
        %  text lines of the image. If LINES is 'ALL', or not given, all
        %  lines are plotted. If LINES is a numeric array, only the lines
        %  in the array are shown.
            if nargin < 2; lines='all'; end
            if ischar(lines) && strcmp(lines,'all')
                lines = this.NumLines:-1:1;
            end
            hold on;
            mask = zeros([1,this.NumLines]);
            mask(lines)=1;
            K = this.LabeledLines;
            for l=1:this.NumLines 
                if ~mask(l)
                    K(K==l)=0;
                end
            end
            image(K);
            for l=lines
                J = this.LabeledLines==l;
                f = this.PolyFit{l};
                if f.x_low + this.MinLineLength < f.x_high
                    x = linspace(f.x_low, f.x_high, this.NumControlPoints);
                    xhat = (x - f.mu(1)) / f.mu(2);
                    [yhat,delta] = polyval(f.p, xhat, f.S);
                    err = this.SigmaFactor * delta;
                    % errorbar(x,yhat,err,'-','Color','r',...
                    %          'LineWidth',0.01);
                    plot(x,yhat,'Color','r','LineWidth',0.01);
                    plot(x,yhat + f.bounds(1),'Color','y','LineWidth',0.01);
                    plot(x,yhat + f.bounds(2),'Color','g','LineWidth',0.01);                    
                else
                    [y,x]=find(J);
                    plot(x,y,'+','Color','magenta','LineWidth',1);
                end
            end
            colormap hot;
            set (gca,'YDir','reverse');
            drawnow;
            hold off;    
        end

        function show_labels(this)
        %SHOW_LABELS Show the original image colored according to line number.
            K=1+mod(17*this.LabeledLines,11);
            imagesc(K);
            colormap hot;
        end

        function shrt = show_short_lines(this, delay)
        %SHOW_SHORT_LINES Display short lines with its long lines above and below
            if nargin < 2; delay=1; end
            [~,shrt] = detect_short_lines(this);
            for s=shrt
                K=zeros([size(this.BW),3]);
                J=this.LabeledLines==s;
                [y,x]=find(J);
                ym = mean(y);    %the average location of the short line in y direction
                xm = mean(x);    %the average location of the short line in x direction
                K(:,:,1) = J;
                nb=long_neighbors(this,s);
                for j=1:length(nb)
                    K(:,:,1+j) = this.LabeledLines==nb(j);
                end
                set(gcf, 'Name', 'Search for unattached diacriticals');
                hold on;
                % Compute the size of joined planes
                R = K(:,:,1) | K(:,:,2) | K(:,:,3);
                [~,b]=LineBreaker.bbox(R);
                clf;
                % Limit colored image
                H = K( b(2):(b(2)+b(4)), b(1):(b(1)+b(3)), : );
                image(b(1),b(2),H);
                centers=[xm,ym]; radii=100;
                viscircles(centers,radii,'Color','r','LineWidth',0.01);
                colormap parula;
                set (gca,'YDir','reverse');
                daspect([1,1,1]);
                hold off;
                drawnow, pause(delay);
            end
        end

        function str = show_line(this, l)
        %SHOW_LINE Shows a line of text with specific line number.
        %  STR = SHOW_LINE(THIS, L) shows line with line number L.
        % It also tries to recognize the line as Pashto language
        % string and returns the string, as well as shows it in the 
        % figure title.
            Line = extract_line(this, l);            
            [str, status] = this.Recognizer.recognize(~Line);
            if status == 0
                set(gcf,'Name',str(1:(end-1)));
            end
            h = imshow(~Line);
        end


        function [LineImage,Box] = extract_line(this, l)
        %EXTRACT_LINE Extract line with label L
        %  [LINEIMAGE,BOX] = EXTRACT_LINE(THIS, L) accepts a LineBreaker
        %  instance and the number of the line number. It returns
        %  the image containing the line and the bounding box BOX of the
        %  line in the original image.
            [LineImage,Box]=LineBreaker.bbox(this.LabeledLines==l);
        end

        function play_lines(this,delay)
            if nargin < 2; delay=1; end
            for l=this.NumLines:-1:1
                this.show_line(l);
                drawnow, pause(delay);
            end
        end

    end

    methods(Static, Access=private)
        function [BWCropped,BBox]=bbox(BW)
        %BBOX Extract the bounding box of a BW image and crop the image.
        %  [BWCROPPED,BBOX] = BBOX(BW) accepts a black-and-white image
        %  BW and it returns a cropped image BWCROPPED and the bounding
        %  box BBBOX.

        % Create a mask
        % Idiom: convert a pixel list to mask
            [I,J]=find(BW);
            % Crop image to bounding box of object
            BBox=[min(J),min(I),range(J),range(I)];
            BWCropped=imcrop(BW,BBox);
        end
    end
end