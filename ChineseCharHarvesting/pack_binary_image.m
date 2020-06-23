function P = pack_binary_image(BW)
%PACK_BINARY_IMAGE - stored binary image in a byte array
%  P = PACK_BINARY_IMAGE(BW) generates an array of bytes P from a binary
%  image BW. The first two bytes are height and width of the image,
%  followed by image data. The image may not not have more than 255 rows
%  or columns.
    [h,w] = size(BW);
    assert(h <= 255 && w <= 255);
    len = h*w;
    BW = BW(:);
    num_bytes = ceil(len / 8);
    BW = padarray(BW, 8*num_bytes-len, 0, 'post');
    P = reshape(BW,[num_bytes,8]);
    P = bi2de(P);
    P = uint8([h;w;P])';
end