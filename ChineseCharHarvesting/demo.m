if ~exist('X','var')
    load('training_data');
end
N=size(X,2);
Xr=reshape(X,[max_h,max_w,N]);
IC=vec2ind(T);                          % Convert one-hot encoded class to index
for k=1:N; 
    clf;
    subplot(1,2,1);
    BW=Xr(:,:,k);
    imagesc(BW);
    title(sprintf('Character %d',k));
    xlim([1,max_w]);
    ylim([1,max_h]);
    subplot(1,2,2);
    chi_str=recognize(BW);
    chi_text(chi_str);
    title(sprintf('Label %s', chi_str));
    drawnow;
    pause(1); 
end


function chi_text(str)
% Draw the characters
    font='Arial';
    fontsize=128;
    hold on;
    s=text(0, 0, str, ...
           'FontSize', fontsize,...
           'FontName',font,...
           'FontUnits','normalized',...
           'Units','normalized');
    r=s.Extent;
    % q=rectangle('Position',[r(1),r(2),r(3)-r(1),r(4)-r(2)],...
    %             'LineWidth', 3, ...
    %             'EdgeColor', 'red');
    m=0;                                % Margin
    xlim([r(1)-m,r(3)+m]);
    ylim([r(2)-m,r(4)+m]);
    hold off;
end
