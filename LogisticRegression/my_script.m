digit0 = 0;
digit1 = 1;
digit2 = 2;
digit3 = 3;
[X,T] = prepare_training_data(digit0,digit1,digit2,digit3);
% Matlab expects samples in columns and T to be a row vector

% Change pixel value to logarithmic odds off being black
%X = log ( (.1 + X) ./ (1 + .1 - X) );


% Insert a column of 1's
X = [ones([size(X,1),1]),X];

% Straight from PATTERNNET help page
num_epochs = 5000;
[Y, NErrors] = train_patternnet(X,T,num_epochs);

figure;
plotconfusion(T',Y');
NErrors