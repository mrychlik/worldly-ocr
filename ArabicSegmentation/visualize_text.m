function visualize_text(objects,lines,right_to_left,get_image, is_diacritical)
narginchk(2,5);
if nargin < 5
    is_diacritical=@(obj)false;
elseif nargin < 4
    get_image=@(obj)uint8(255.*obj.bwimage);
elseif nargin < 3
    right_to_left=false;
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
            image([x,x+w],[y,y+h],K),drawnow;
        else
            image([x,x+w],[y,y+h],J),drawnow;
        end

        % Plot character bounding boxes only
        rectangle('Position',[x,y,w,h],'EdgeColor','green');
        %colormap winter;
    end
end
hold off;

