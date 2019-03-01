function Dis = dissimilarity(obj1, obj2)
    F1 = fft2(obj1.grayscaleimage);
    F2 = fft2(obj2.grayscaleimage);
    G = (F1 .* conj(F2)) ./ (eps + abs(F1) .* abs(F2));
    H = abs(ifft2(G));
    F = zeros(size(H));
    F(1:2,1:2) = 1;
    F(1:2,(end-1):end) = 1;
    F((end-1):end,1:2) = 1;
    F((end-1):end,(end-1):end) = 1;
    K = ifft2(fft2(H) .* fft(F));
    Dis=max(abs(K(:)));
end
