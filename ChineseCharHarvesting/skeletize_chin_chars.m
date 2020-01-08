imds = imageDatastore(fullfile('.','BWChars'),'FileExtensions',{'.pbm'});
dstdir = fullfile('.','SkelBWChars');

cnt = 0;
while hasdata(imds)
    cnt = cnt+1;
    [I,info] = read(imds);
    S=bwskel(I);
    [~,b,c]=fileparts(info.Filename);
    dstfile = fullfile(dstdir,[b,c])
    imwrite(S,dstfile);
end