function chi_visualize_text(lines)
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
    disp(['Line',num2str(l)]);
    l_objs=lines{l};
    rng=numel(l_objs):-1:1;
    for j=rng
        disp(['Object',num2str(j)]);
        if isempty(l_objs{j})
            continue;
        end
        r=l_objs{j}.bbox;
        x=r(1)-1;y=r(2)-1;w=r(3);h=r(4);
        % Plot characters
        J=255.*l_objs{j}.bwimage;
        image([x,x+w],[y,y+h],J),drawnow;
        % Plot character bounding boxes only
        rectangle('Position',[x,y,w,h],'EdgeColor','green');
        rr=l_objs{j}.rect;
        if ~isempty(rr)
            x=x+rr(1)-1;
            y=y+rr(2)-1;
            w=rr(3);
            h=rr(4);
            rectangle('Position',[x,y,w,h],'EdgeColor','red');
        end
        colormap hot;
    end
end
hold off;

