load('training_data');
N=size(X,2);
X=reshape(X,[max_h,max_w,N]);
for k=1:N; 
    imagesc(X(:,:,k));
    title(sprintf('Character %d',k));
    drawnow;
    pause(0.01); 
end