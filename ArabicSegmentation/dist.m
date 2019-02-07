function d = dist(ob1,ob2)
d = min(pdist2(ob1.PixelList, ob2.PixelList))
end