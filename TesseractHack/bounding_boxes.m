function [objects,lines]=bounding_boxes(I,varargin)
%BoundingBoxes determines bounds of characters in scanned text
% [OBJECTS,LINES]=BOUNDING_BOXES(I) accepts as an argument
% a grayscale image with white-on-black printed characters
% It returns:
%    - OBJECTS    - an array of character objects.
%    - LINES      - a cell array; each cell contains
%                 - a list of object indices forming
%                   a horizontal line.
% Options:
%   - 'Display'          - illustrate various steps with graphics
%   - 'Method'           - The method to assign line number to object
%   - 'DiacriticalMarks' - Try to augment characters with their
%                          diacritical marks
%                   
narginchk(1,inf);

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
            disp(['Display is ', Display]);
          otherwise
            error('''Display'' option value is invalid.');
        end
      case 'Method'
        assert(isa(val,'char'));
        switch val
          case {'kmeans','lloyds'}
            Method=val;
            disp(['Method is ', Method]);
          otherwise
            error('''Method'' option value is invalid.');
        end
      case 'DiacriticalMarks'
        assert(isa(val,'char'));
        switch val
          case {'on','off'}
            DiacriticalMarks=val;
            disp(['DiacriticalMarks are ',DiacriticalMarks]);
          otherwise
            error('''DiacriticalMarks'' option value is invalid.');
        end
      otherwise
        error('Invalid option: key=%s, value=%s',key,val);
    end
end
% Initialize default values
if ~exist('Display','var'); Display='off'; end
if ~exist('DiacriticalMarks','var'); DiacriticalMarks='on'; end
if ~exist('Method','var'); Method='kmeans'; end

%% Use a bw image to see where the objects are
%level = graythresh(I);
%level=.8;
%BW=im2bw(I,level);
BW=I;
%imshow(BW);
%% Find connected components and extract region properties
objects=im2objects(BW);
[objects,gap_centers]=line_breaks(BW, objects, ...
                                  'Display', Display,...
                                  'Method', Method);
num_objects=numel(objects);
num_lines=numel(gap_centers)+1;

%% Compute characters in each line
lines=cell(num_lines,1);
for l=1:num_lines
    lines{l}=[];
end
for ob=1:num_objects
    l=objects(ob).line_num;
    if l>=0
        lines{l}=[lines{l},ob];
    end
end
%Remove empty lines
l_cnt=0;
for l=1:num_lines
    if ~isempty(lines{l})
        l_cnt=l_cnt+1;
        if(l_cnt~=l)
            lines{l_cnt}=lines{l};
        end
    end
end
lines=lines(1:l_cnt);
num_lines=l_cnt;

%% Sort characters in each line by x-coordinates
for l=1:l_cnt;
    l_len=length(lines{l});
    x=zeros(l_len,1);
    % Collect positions of characters
    for j=1:l_len
        ob=lines{l}(j);
        x(j)=objects(ob).BoundingBox(1)+1;
    end
    [xs,ix]=sort(x);
    % Sort line according to the x coordinate
    lines{l}=lines{l}(ix);
end


if strcmp(Display,'on')
    % Show text images in their boxes
    visualize_text(objects,lines,true);
end

function objects=im2objects(BW)
%% Find connected components and extract region properties
stats=regionprops(BW,'BoundingBox','PixelList','Centroid',...
                  'FilledArea','ConvexArea','Area','PixelList','EulerNumber');

%% Extract images of individual objects
num_objects=numel(stats);
h=waitbar(0,'Extracting object info...');
for ob=1:num_objects
    waitbar(ob/num_objects,h);
    mask=zeros(size(BW),'uint8');
    pixellist=stats(ob).PixelList;
    % Crop image to bounding box of object
    mask(sub2ind(size(mask),pixellist(:,2), pixellist(:,1))) = 1;
    % Add some components to objects
    s=stats(ob);
    r=s.BoundingBox;
    objects(ob).BoundingBox=r;
    objects(ob).width=r(3);
    objects(ob).height=r(4);
    objects(ob).Centroid=s.Centroid;
    objects(ob).FilledArea=s.FilledArea;
    objects(ob).PixelList=s.PixelList;
    objects(ob).ConvexArea=s.ConvexArea;
    objects(ob).EulerNumber=s.EulerNumber;
    objects(ob).bwimage=imcrop(and(BW,mask),r);
end;
close(h);
end

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
    disp('Visualizing gap centers');
    BW_lines=double(BW);
    BW_lines(gap_centers+1,:)=1;
    BW_lines(gap_centers,:)=1;
    BW_lines(gap_centers-1,:)=1;
    if strcmp(Display,'on')
        figure;
        imshow(BW_lines);
        title('Gap center lines');
    end
end