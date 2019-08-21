% This script tests the new regularization method

digit0 = 0;
digit1 = 1;
digit2 = 2;
digit3 = 3;
[X,T] = prepare_training_data(digit0,digit1,digit2,digit3);
% Matlab expects samples in columns and T to be a row vector


% Straight from PATTERNNET help page
num_epochs = 5000;
[Y, NErrors,W] = train_patternnet_w_regularizer(X,T,num_epochs);

figure;
plotconfusion(T,Y);
NErrors


