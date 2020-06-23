%
% This version learns 1000 characters and reaches perfect recognition
%
[X,T] = prepare_training_data;

% Matlab expects samples in columns and T to be a row vector

% Insert a row of 1's
X = [ones([1,size(X,2)]);X];

% Pick a subsample
N=1000;
X=X(:,1:N);
T=T(:,1:N);


% Straight from PATTERNNET help page
num_epochs = 100000;
minibatch_size = 128;
eta=2e-2;
[Y, NErrors, W] = train_patternnet(X,T,num_epochs,minibatch_size);

for j=1:10
    [Y, NErrors, W] = train_patternnet(X,T,num_epochs,minibatch_size,eta,W);
end

NErrors
save('best_weights_1k','W');