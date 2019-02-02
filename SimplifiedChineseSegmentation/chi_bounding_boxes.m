function lines=chi_bounding_boxes(I,varargin)
%BoundingBoxes determines bounds of characters in scanned text
% LINES=BOUNDING_BOXES(I) accepts as an argument
% a grayscale image with white-on-black printed characters
% It returns LINES, which is a nested cell array of 1-D cell arrays.
% Each nested cell array contains line objects (images plus metadata).

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
    vert_gap_centers=chi_line_breaks_by_change(BW, Display);

    % Display lines

    vert_gap_centers=[1;vert_gap_centers];
    num_lines=numel(vert_gap_centers);
    lines=cell(num_lines,1);
    for l=1:num_lines
        lines{l}=[];
    end
    for j=1:(numel(vert_gap_centers)-1); 
        LineImg=BW(vert_gap_centers(j):vert_gap_centers(j+1),:);
        if Display
            imshow(LineImg),drawnow;
        end
        hor_gap_centers=chi_line_breaks_by_change(LineImg',Display);
        hor_gap_centers=[1;hor_gap_centers];
        num_chars=numel(hor_gap_centers);
        lines{j}=cell(num_chars,1);
        for k=1:(numel(hor_gap_centers)-1);
            CharImg=LineImg(:,hor_gap_centers(k):hor_gap_centers(k+1));
            if Display
                imshow(CharImg),drawnow;
            end
            width=hor_gap_centers(k+1)-hor_gap_centers(k)+1;
            height=vert_gap_centers(j+1)-vert_gap_centers(j)+1;        
            bbox=[hor_gap_centers(k),vert_gap_centers(j),width,height];
            [J,rect]=imautocrop(CharImg);
            obj=struct('bwimage',CharImg,...
                       'bbox',bbox,...
                       'croppedimage',J,...
                       'rect',rect);
            lines{j}{k}=obj;
        end
    end

end
