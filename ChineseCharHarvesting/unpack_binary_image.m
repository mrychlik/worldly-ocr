function BW = unpack_binary_image(P)
%UNPACK_BINARY_IMAGE - undoes PACK_BINARY_IMAGE
h = P(1); w = P(2);
P = P(3:end)';
bits = de2bi(P,8));
bits = bits(:);
bits = bits(1:(uint16(h)*uint16(w)));
BW = reshape(bits,[h,w]);
end