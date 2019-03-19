function [objects,gap_centers]=line_breaks(BW, objects, varargin)
% [OBJECTS,GAP_CENTERS]=LINE_BREAKS(BW, OBJECTS) finds lines
%   breaks in the scanned text represented by image BW.
% OBJECTS is modified, by adding line numbers to objects.
% The following options are accepted:
%  - 'Display'; if 'on' or 'of'; if 'on', graphical output
%              visualising text partitioning into lines
%              is presented
%  - 'Method';  'kmeans' or 'lloyds'
    options=varargin;
    num_options=length(options);
    if mod(num_options,2)~=0
        error('Number of options must be even.');
    end;
    num_options=num_options/2;
    % Parse command line options
    for opt=1:num_options
        key=options{2*opt-1};
        val=options{2*opt};
        assert(isa(key,'char'));
        switch key,
          case 'Display'
            assert(isa(val,'char'));
            switch val
              case {'on','off'}
                Display=val;
              otherwise
                error('''Display'' option value is invalid.');
            end
          case 'Method'
            assert(isa(val,'char'));
            switch val
              case {'kmeans','lloyds'}
                Display=val;
              otherwise
                error('''Method'' option value is invalid.');
            end
          otherwise
            error('Invalid option: key=%s, value=%s',key,val);
        end
    end
    % Initialize default values
    if ~exist('Display','var'); Display='off'; end
    if ~exist('Method','var'); Method='kmeans'; end

    switch Method,
      case 'kmeans'
        [objects,gap_centers]=...
            line_breaks_by_kmeans(BW, objects, Display);
      case 'lloyds'
        [objects,gap_centers]=...
            line_breaks_by_lloyds(BW, objects, Display);
    end
end

function [objects,gap_centers]=line_breaks_by_kmeans(BW, objects, Display)
% Find line breaks by K-Means
    P=sum(BW,2);                        % Project the image onto the y-axis
    [P_idx,P_C,SUMD]=kmeans(P,2);

    % Visualize the count of pixels in scan lines
    if strcmp(Display,'on')
        scatter(1:length(P),P,5,P_idx);
    end

    % Theshold for y-coordinate to be considered within a break
    P_C=sort(P_C);
    level=P_C(1);

    % Indicator function of pixels between lines.
    bl=P<level;

    % Visualize areas between lines; plateaus are areas between lines
    if false 
        if strcmp(Display,'on')
            plot(cumsum(bl));
        end
    end

    % Number the gaps between lines
    gap_nums=zeros(size(P));
    gap_cnt=0;
    bl_flag=false;
    for l=1:size(P,1)
        if bl_flag
            if bl(l)==0                     % We are not between lines
                bl_flag=false;
                gap_nums(l)=-1;
            else                            % bl(l)==1
                gap_nums(l)=gap_cnt;
            end
        else                                % ~bl_flag
            if bl(l)==0                     % We are not between lines
                gap_nums(l)=-1;
            else                            % bl(l)==1
                gap_cnt=gap_cnt+1;
                gap_nums(l)=gap_cnt;
                bl_flag=true;
            end
        end
    end

    %% Plot gap numbers
    num_gaps=gap_cnt;
    if strcmp(Display,'on')
        figure;
        bar(gap_nums),
        title('Gap numbers as function of y'),
        xlabel('y'),
        ylabel('Gap number');
    end

    % Visualize gaps
    %figure;
    %BW_lines=double(BW);
    %BW_lines(gap_nums>0,:)=1;
    %imshow(BW_lines);
    %title('Gaps between lines');

    %% Find centers of gaps
    gap_centers=zeros(num_gaps,1);
    for g=1:num_gaps
        gap_centers(g)=round(mean(find(gap_nums==g)));
    end;
    %%

    visualize_gap_centers(BW, gap_centers, Display);

    %% Compute line numbers of characters
    line_nums=zeros(size(BW,1),1);
    line_nums(gap_centers)=1;
    line_nums=cumsum(line_nums);
    num_lines=line_nums(end);


    %% Add line numbers to objects
    for ob=1:length(objects)
        y=ceil(objects(ob).Centroid(2));
        if (y <= length(line_nums)) && (line_nums(y) > 0);
            objects(ob).line_num=line_nums(y);
        else
            warning('Object %d has no line number',ob);
            objects(ob).line_num=-1;
        end
    end
end


function [objects,gap_centers]=line_breaks_by_lloyds(BW, objects, Display)
% Find line breaks by Lloyd's algorithm
    num_lines=24;
    P=cellfun(@(x)x(2),{objects.Centroid});
    [partition,codebook]=lloyds(P,num_lines);
    idx=quantiz(P,partition,codebook);
    if Display
        plot(codebook(idx+1),P,'.');
    end
    gap_centers=partition;

    %% Add line numbers to objects
    for ob=1:length(objects)
        objects(ob).line_num=idx(ob);
    end

    visualize_gap_centers(BW, gap_centers, Display);
end

function visualize_gap_centers(BW, gap_centers, Display)
    if strcmp('Display','on'); display = true; else display=false;end;
    if display; disp('Visualizing gap centers'); end
    BW_lines=double(BW);
    BW_lines(gap_centers+1,:)=1;
    BW_lines(gap_centers,:)=1;
    BW_lines(gap_centers-1,:)=1;
    if display
        figure;
        imshow(BW_lines);
        title('Gap center lines');
    end
end