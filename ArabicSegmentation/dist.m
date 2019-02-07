function d = dist(ob1,ob2)
A = pdist2(ob1.BoundingBox, ob2.BoundingBox, @bbox_dist);
d = min(A(:));
end

function d = bbox_dist(b1, b2)
    d1 = ival_dist([b1(1),b1(1)+b1(3)],[b2(1),b2(1)+b2(3)]);
    d2 = ival_dist([b1(2),b1(2)+b1(4)],[b2(2),b2(2)+b2(4)]);
    d = min(d1, d2);
end    

function d = ival_dist(i1, i2)
    if i1(1) > i2(2)
        d = i2(2) - i1(1)
    elseif i1(2) < i2(1)
        d = i2(1) - i1(2)
    else
        d = 0
    end
end