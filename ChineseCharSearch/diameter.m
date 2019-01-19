function diam=diameter(sz, pt, pts)
% Compute diameter of a set on the torus
    distfun=@(x)min(mod(x-pt,sz), mod(pt-x,sz));
    D=zeros([size(pts,1),1]);
    for j=1:size(pts,1)
        D(j)=max(distfun(pts(j,:)));
    end
    diam=max(D);
end
