load('training_data');
N=size(X,2);
X=reshape(X,[max_h,max_w,N]);
for k=1:N; 
    imagesc(X(:,:,k));
    drawnow;
    pause(1); 
end