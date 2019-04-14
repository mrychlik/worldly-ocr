[X,T] = prepare_training_data;

% Matlab expects samples in columns and T to be a row vector

% Insert a row of 1's
X = [ones([1,size(X,2)]);X];

% Straight from PATTERNNET help page
num_epochs = 500;
[Y, NErrors, W] = train_patternnet(X,T,num_epochs);

NErrors