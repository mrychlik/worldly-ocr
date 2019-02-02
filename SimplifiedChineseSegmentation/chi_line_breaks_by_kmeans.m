function gap_centers=chi_line_breaks_by_kmeans(BW, Display)
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
        clf,
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

    visualize_gap_centers(BW, gap_centers, Display);
end

