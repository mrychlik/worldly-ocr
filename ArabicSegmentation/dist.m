function d = dist(ob1,ob2)
A = pdist2(ob1.PixelList, ob2.PixelList);
d = min(A(:));
end