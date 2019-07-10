% Determine the top and bottom of the page as a geomeric line
% Use Hough transform
pagedir='Pages';
page_img_pattern='page-%02d.ppm';
if ~exist('pages','var') pages=6:95; end;

keep_outliers=false;
nhood_size = [81,89];           % Suppression neighborhood size

for page=6:95
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    BW = ps.Boundary';
    Theta = linspace(-10,10,100);
    [H,T,R] = hough(BW,'Theta',Theta);
    npeaks = 2;
    P=houghpeaks(H,npeaks, 'NHoodSize',nhood_size);
    subplot(1,2,1)
    hold on;
    imshow(imadjust(rescale(H)),'XData',T,'YData',R/500,...
           'InitialMagnification','fit');
    plot(T(P(:,2)),R(P(:,1))/500,'o','color','red','LineWidth',10);
    title(sprintf('T(1): %.2f, T(2): %.2f', T(P(1,2)), T(P(2,2))));
    hold off;
    subplot(1,2,2);
    % Flip vertical axis upside down
    set(gca,'YDir','reverse');
    hold on;
    % Make background black
    im=image(255*ps.PageImageMono');
    im.AlphaData = 0.2;
    % The equation of the line is R=cos(T)*x+sin(T)*y
    % where T is small, thus cos(T)~=0. Hence, x = (R-sin(T)*y)/cos(T)
    for j=1:size(P,1)
        t=T(P(j,2))./90;
        r=R(P(j,1));
        y=1:size(BW,1);
        x=(r-sin(t).*y)./cos(t);
        plot(x,y,'Color','red','LineWidth',3);
    end
    hold off;
    colormap(hot);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;

