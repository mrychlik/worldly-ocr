function gap_centers=chi_line_breaks_by_lloyds(BW, Display)
% Find line breaks by Lloyd's algorithm
%% TODO: This does not work yet!!!
    num_lines=24;
    P=sum(BW,2);
    [partition,codebook]=lloyds(P,num_lines);
    idx=quantiz(P,partition,codebook);
    if Display
        plot(codebook(idx+1),P,'.');
    end
    gap_centers=round(partition)';
    visualize_gap_centers(BW, gap_centers, Display);
end
