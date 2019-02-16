if ~exist('cropped','var');
    load('cropped.mat');
end

for idx=1:nsamples
    I = cropped(idx).image;
    r = cropped(idx).bbox;
    image(r(1)-w/2, r(2)-h/2, 255-I), 
    xlim([-w/2,w/2]), 
    ylim([-h/2,h/2]),
    colormap gray,
    drawnow; 
    pause(.1);
end
