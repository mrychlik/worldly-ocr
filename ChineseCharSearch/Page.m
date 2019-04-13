classdef Page
    properties(Access=private)
        dr = 7;                         % Size of side column margins
        dy = 20;                        % Size of top/bottom column margin
        col_width_min = 25;             % Minimal column width
        I=[];                           % Page image
        AutoCropColumns = true;         % Autocrop columns?
        nhood_size = [81,89];           % Suppression neighborhood size
        Interpolate = true;             % Whether to interpolate between
                                        % Hough peaks
        max_skew = 4;                   % Maximal skew in degrees
        bw_threshold = 0.3;             % Threshold for gray to be
                                        % considered black
        top_margin_size = 150;          % Margin at the top without characters
    end

    properties(Access=public)
        numCols = -1;                   % Number of columns
        vertSize = -1;                  % Number of pixel rows
        horzSize = -1;                  % Number of pixel columns
        page = -1;                      % Page number
        cols = struct('bwimage',[]);    % Columns
        Display;                        % Display graphical feedback
        idx2colNum;                     % Maps y-coordinate to column index
        colOffsets;                     % y-offsets of the columns in
                                        % linear order.
        tallImage;                      % Stacked columns
        H;                              % Hough transform
        T;                              % Angles of Hough transform
        R;                              % Radii of Hough transform
        P;                              % Peaks of Hough transform
    end;

    methods(Access=public)
        function obj = Page(I,varargin)
        % A Page constructor
        %   OBJ = PAGE(I,VARARGIN) constructs a Page object from the
        % image I, and options:
        %   Display    - 'on' (default) or 'off'; if 'on', provide graphical feedback
        %   PageNumber - numeric; the page label of the page object
            p=parse_args(obj,I,varargin{:});
            obj.I=p.Results.I;
            obj.Display=p.Results.Display;
            obj.page = p.Results.PageNumber;
            obj.I=255-obj.I;
            [obj.H,obj.T,obj.R,obj.P]=vertical_dividers(obj);
            [X,Y]=meshgrid(1:size(I,2),1:size(obj.I,1));

            obj=fix_peaks(obj);

            if strcmp(obj.Display,'on')
                subplot(1,3,1),imagesc(obj.I), 
                title(['Page: ',num2str(obj.page)]),
                drawnow;
            end

            obj.numCols=size(obj.P,1)-1;
            obj.colOffsets=zeros(1,obj.numCols);
            obj.cols=struct('bwimage',zeros(obj.numCols,1));
            y=0;
            xMax=-1;
            NumRowsMax=obj.numCols .* size(obj.I,1);
            obj.idx2colNum = zeros(NumRowsMax,1);
            obj.tallImage =  zeros(NumRowsMax,0);

            for j=1:obj.numCols
                obj.colOffsets(j)=y;
                t1=obj.T(obj.P(j,2))./90;
                r1=obj.R(obj.P(j,1));
                t2=obj.T(obj.P(j+1,2))./90;    
                r2=obj.R(obj.P(j+1,1));    
                U=(X*cos(t1)+Y*sin(t1)<r1-obj.dr) & ...
                  (X*cos(t2)+Y*sin(t2)>r2+obj.dr);
                J=im2bw(obj.I,obj.bw_threshold);
                J(~U)=0;
                J(1:90,:)=0;
                J((end-80):end,:)=0;        
                if strcmp(obj.Display,'on')
                    subplot(1,3,2),
                    imagesc(J),
                    title(['Column: ',num2str(j)]),
                    drawnow;
                end
                J=imrotate(J,t1*90);
                if obj.AutoCropColumns
                    J=imautocrop(J);
                end
                [xl,xh]=bounds(find(sum(J,1)>0));
                J=J(:,xl:xh);
                subplot(1,3,3),imshow(~J),drawnow;
                obj.cols(j).bwimage=J;
                obj.idx2colNum((y+1):(y+size(J,1)))=j;
                colWidth=xh-xl+1;
                xMax=max(xMax,colWidth);
                dx=xMax-size(obj.tallImage,2);
                obj.tallImage=padarray(obj.tallImage,[0,dx],0,'post');
                obj.tallImage((y+1):(y+size(J,1)),1:colWidth)=J;
                y=y+size(J,1);
            end
            obj.vertSize=y;
            obj.tallImage=obj.tallImage(1:y,:);
            obj.horzSize=xMax;
        end

        function obj=fix_peaks(obj)
        % Using some heuristics, improve the Hough transform peaks
        %   OBJ=FIX_PEAKS(OBJ) modifies the peaks array, in the following
        % ways:
        %   - The peaks are sorted in descending order of the radius; this
        %     corresponds to ordering dividers from right to left.
        %   - Missing dividers are inserted by interpolating between the
        %     peaks found, if the distance between dividers looks too large.
            obj.P=sortrows(obj.P,1,'descend');

            % Interpolate if skip too big
            if obj.Interpolate
                r = -diff(obj.P(:,1));
                r = r(r>=obj.col_width_min); % Remove low outliers
                r = min(r);
                jj = size(obj.P,1)+1;
                n = size(obj.P,1)-1;
                QQ=[];
                for j=1:n
                    k = round((obj.P(j,1)-obj.P(j+1,1))./r);
                    if k > 1
                        for l=1:(k-1)
                            Q=(1-l./k).*obj.P(j,:)+(l./k).*obj.P(j+1,:);
                            Q=round(Q);
                            QQ=[QQ;Q];
                        end
                    end
                end
                num_new_cols=size(QQ,1);
                if num_new_cols > 0
                    warning('MRToolbox:fix_peaks:interpolation',...
                            ['Interpolation inserted ',num2str(num_new_cols),...
                             ' column(s).']);
                    obj.P=[obj.P;QQ];
                    obj.P=sortrows(obj.P,1,'descend');
                end
            end
        end
    end

    methods(Access=private)

        function p=parse_args(obj,I,varargin)
            p=inputParser;
            addRequired(p,'I',@isnumeric);

            defaultDisplay='on';
            validDisplays={'on','off'};
            checkDisplay=@(x)any(validatestring(x,validDisplays));
            addOptional(p,'Display',defaultDisplay, checkDisplay);

            addOptional(p,'PageNumber',obj.page, @isnumeric);

            parse(p,I,varargin{:});
        end

        function [H,Theta,R,P]=vertical_dividers(obj)
        % Use the vertical lines as guides to divide page into columns
        %   [H,THETA,R,P]=VERTICAL_DIVIDERS(OBJ) accepts a Page object
        % and it returns
        % H     - The hough transform of the page image
        % Theta - The 'theta' grid (angles)
        % R     - The 'r' grid (radii)
        % P     - The peaks of the Hough transform, hopefully related
        %         to the page dividers.
            BW=im2bw(obj.I,obj.bw_threshold);
            obj.top_margin_size;
            BW(1:obj.top_margin_size,:)=0;
            BW((end-margin_sz):end,:)=0;    
            if strcmp(obj.Display,'on')
                imshow(BW);
            end
            % Find Hough transform
            Theta=linspace(-obj.max_skew,obj.max_skew,100);
            se1=strel('line',2,0);        
            BW1=imdilate(BW,se1);
            if strcmp(obj.Display,'on')
                imshow(BW1);
            end        
            [H,T,R]=hough(BW1,'Theta',Theta);
            npeaks=12;
            P=houghpeaks(H,npeaks,...
                         'Threshold',0.75*max(H(:)),...
                         'NHoodSize',obj.nhood_size);
            clf;
            if strcmp(obj.Display,'on')
                subplot(1,2,1);
                imshow(H,[],...
                       'XData',T,...
                       'YData',R,...
                       'InitialMagnification','fit');
                set(gca,'YLim',[0,600]);
                xlabel('\theta'), ylabel('\rho');
                axis on, axis normal, hold on;
                plot(T(P(:,2)),R(P(:,1)),'o','color','red','LineWidth',10);
                subplot(1,2,2);
                hold on;
                % Flip vertical axis upside down
                set(gca,'YDir','reverse');
                % Make background black
                %whitebg('black');
                %image([0 size(BW,2)], [0 size(BW,1)], 255.*BW1);
                image([0 size(BW,2)], [0 size(BW,1)], obj.I);
                % The equation of the line is R=cos(T)*x+sin(T)*y
                % where T is small, thus cos(T)~=0. Hence, x = (R-sin(T)*y)/cos(T)
                for j=1:size(P,1)
                    t=T(P(j,2))./90;
                    r=R(P(j,1));
                    y=1:size(BW,1);
                    x=(r-sin(t).*y)./cos(t);
                    plot(x,y,'Color','red','LineWidth',3);
                end
                hold off;
            end
        end

    end
end