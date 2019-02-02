function gap_centers=chi_line_breaks_by_change(BW, Display)
% Find line breaks by K-Means
    P=sum(BW,2);                        % Project the image onto the y-axis
    P=[1;P];
    gaps=double(P==0);
    dgaps=diff(gaps);
    enter_gap=find(dgaps==1);
    exit_gap=find(dgaps==-1);
    num_gaps=min(numel(enter_gap),numel(exit_gap));
    gap_centers=round((enter_gap(1:num_gaps)+exit_gap(1:num_gaps))./2);

    visualize_gap_centers(BW, gap_centers, Display);
end

