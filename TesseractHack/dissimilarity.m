function Dis = dissimilarity(obj1, obj2)
    F1 = fft2(obj1.grayscale);
    F2 = fft2(obj2,grayscale);
    G = (F1 * cons(F2)) / (eps + abs(F1)*abs(F2));
    H = abs(ifft2(G));
    Dis = entropy(H(:));
end
