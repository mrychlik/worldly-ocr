c = 'A';
FontSize = 60;

fh = gcf;
set(fh, 'Units', 'pixels', 'Color', [1,1,1]);
ax=axes(fh,'Position',[0 0 1 1],'Units','Normalized','visible','on');
axis off;

th = text(ax, 0,0,c,'FontSize', FontSize, 'Interpreter','none','Units', ...
          'pixels','HorizontalAlignment','Left','VerticalAlignment','Bottom');

get(th)

ex = round(get(th,'Extent'));

%xlim([bbox(1),bbox(1)+bbox(3)]);
%ylim([bbox(2),bbox(2)+bbox(4)]);

F = getframe(fh);

BW = im2bw(F.cdata);
[h,w] = size(BW);


bbox=[ex(1)+1,h-ex(4),ex(3)-1,ex(4)];


im = imshow(BW); im.AlphaData=0.5;
rectangle('Position', bbox);

imagesc(BW( bbox(2):(bbox(2)+bbox(4)), bbox(1):(bbox(1)+bbox(3))));