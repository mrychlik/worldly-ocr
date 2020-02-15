function visualize_text(objects,lines,varargin)
p=inputParser;
p.addRequired('objects');
p.addRequired('lines');
p.addParameter('TextDirection','LeftToRight');
get_image_default=@(obj)uint8(255.*obj.bwimage);
p.addParameter('GetImageFunction',get_image_default);
is_diacritical_default=@(obj)false;
p.addParameter('IsDiacriticalFunction',is_diacritical_default);
p.addParameter('Display',true,@islogical);
p.parse(objects,lines,varargin{:});

get_image=p.Results.GetImageFunction;
is_diacritical=p.Results.IsDiacriticalFunction;
draw_now=p.Results.Display==true;

switch p.Results.TextDirection,
  case 'LeftToRight',
      right_to_left=false;
  case 'RightToLeft',
    right_to_left=true;
end


disp('Visualizing lines of text.');
l_cnt=size(lines,1);
figure;
clf;
% Flip vertical axis upside down
set(gca,'YDir','reverse');
% Make background black
whitebg('black');
hold on;
for l=1:l_cnt
    % Line objects
    l_objs=objects(lines{l});
    if right_to_left
        rng=numel(lines{l}):-1:1;
    else
        rng=1:numel(lines{l});
    end
    for j=rng
        r=l_objs(j).BoundingBox;
        x=r(1);y=r(2);w=r(3);h=r(4);
        % Plot characters
        J=get_image(l_objs(j));
        if is_diacritical(l_objs(j))
            K=zeros([size(J),3]);
            K(:,:,1)=J;
            K(:,:,2)=J;
            bbox_color = 'red';
        else
            K = J;
            bbox_color = 'green';
        end

        % Plot character bounding boxes only
        rectangle('Position',[x,y,w,h],'EdgeColor',bbox_color);
        im = image([x,x+w],[y,y+h],K);
        im.AlphaData=0.5;               % Make image a bit transparent
        colormap hot;
        if draw_now
            drawnow;
        end
    end
end
hold off;

