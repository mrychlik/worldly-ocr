if ~exist('X','var')
    load('training_data');
end
N=size(X,2);
Xr=reshape(X,[max_h,max_w,N]);
IC=vec2ind(T);                          % Convert one-hot encoded class to index
for k=1:N; 
    clf;
    subplot(1,2,1);
    imagesc(Xr(:,:,k));
    title(sprintf('Character %d',k));
    xlim([0,max_w]);
    ylim([0,max_h]);
    subplot(1,2,2);
    chi_text(C{IC(k)});
    title(sprintf('Class label index: %d',IC(k)));
    drawnow;
    pause(2); 
end


function chi_text(str)
% Draw the characters
    font='Arial';
    fontsize=64;
    hold on;
    s=text(0, 0, str, ...
           'FontSize', fontsize,...
           'FontName',font);
    r=s.Extent;
    q=rectangle('Position',[r(1),r(2),r(3)-r(1),r(4)-r(2)],'LineWidth',3);
    m=0.1;                            % Margin
    xlim([r(1)-m,r(3)+m]);
    ylim([r(2)-m,r(4)+m]);
    hold off;
end