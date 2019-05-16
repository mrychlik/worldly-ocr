load('training_data');
N=size(X,2);
X=reshape(X,[max_h,max_w,N]);
for k=1:N; 
    clf;
    subplot(1,2,1);
    imagesc(X(:,:,k));
    title(sprintf('Character %d',k));
    subplot(1,2,2);
    title('Label: %s',C{k});
    chi_text(C{k});
    drawnow;
    pause(2); 
end


function chi_text(str)
% Draw the characters
    font='Arial';
    fontsize=144;
    s=text(0, 0.015, str, ...
           'FontSize', fontsize,...
           'FontName',font);
    r=s.Extent;
    %q=rectangle('Position',[r(1),r(2),r(3)-r(1),r(4)-r(2)],'LineWidth',1);
    m=0.1;                                 % Margin
                                           % xlim([r(1)-m,r(3)+m]);
                                           % ylim([r(2)-m,r(4)+m]);
    xlim([0,0.2]);
    ylim([0,0.03]);
end