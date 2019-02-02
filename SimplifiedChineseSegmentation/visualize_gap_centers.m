function visualize_gap_centers(BW, gap_centers, Display)
    disp('Visualizing gap centers');
    BW_lines=double(BW);
    Z=zeros([size(BW_lines),3]);
    for j=1:3
        Z(:,:,j)=BW_lines;
    end
    BW_lines=Z;
    for j=1:numel(gap_centers)
        BW_lines(max(gap_centers(j)-1,1):min(gap_centers(j)+1,...
                                             size(BW, 1)),:,1)=1;
    end
    if strcmp(Display,'on')
        imshow(BW_lines);
        title('Gap center lines');
    end
end