function D = dissimilarity_matrix(objects)
n = length(objects);
D = zeros(n,n);
for j=1:n
    for k=j:n
        D(j,k) = dissimilarity(objects(j),objects(k));
    end
    imagesc(D > 0.5),drawnow;
end
D = D + D';