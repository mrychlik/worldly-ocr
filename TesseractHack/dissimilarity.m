function Dis = dissimilarity(obj1, obj2)
    F1 = fft2(obj1.grayscaleimage);
    F2 = fft2(obj2.grayscaleimage);
    G = (F1 .* conj(F2)) ./ (eps + abs(F1) .* abs(F2));
    H = abs(ifft2(G));
    K = H + circshift(H,1,1) + circshift(H,1,2) + circshift(H,-1,1) + circshift(H,-1,2);
    Dis=max(abs(K(:)));
end
