load('training_data');
N=size(X,2);
X=reshape(X,[max_h,max_w,N]);
for k=1:N; 
    imagesc(X(:,:,k));
    title(sprintf('Character %d, label: %s',k,C{k}));
    drawnow;
    pause(0.05); 
end