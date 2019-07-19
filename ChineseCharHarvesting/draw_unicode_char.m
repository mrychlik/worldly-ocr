c = 'A';
FontSize = 60;

fh = gcf;
set(fh, 'Units', 'pixels', 'Color', [1,1,1]);
ax = axes(fh,'Position',[0 0 1 1],'Units','Normalized','visible','on');
axis off;

th = text(ax, 0,0,c,'FontSize', FontSize, 'Interpreter','none','Units', ...
          'pixels','HorizontalAlignment','Left','VerticalAlignment','Bottom');

get(th)

ex = get(th,'Extent');

F = getframe(fh);

BW = im2bw(F.cdata);
[h,w] = size(BW);


bbox=round([ex(1)+1,h-ex(4)-1,ex(3),ex(4)]);


im = imshow(BW); im.AlphaData=0.5;
rectangle('Position', bbox);

imagesc(BW( bbox(2):(bbox(2)+bbox(4)), bbox(1):(bbox(1)+bbox(3))));