% This script uses regularization by occasionally selecting class at random

digit0 = 0;
digit1 = 1;
digit2 = 2;
digit3 = 3;
[X,T] = prepare_training_data(digit0,digit1,digit2,digit3);
% Matlab expects samples in columns and T to be a row vector

% Find training data dimensions
[D,N] = size(X);
[C,~]=size(T);

% Add regularizing sample
% It assumes that a 1-pixel image can be
% classified with equal probability to every class
epsilon = 3e-3;




T1 = (1-epsilon)*T+ epsilon*1/C*ones(C,N);

% Straight from PATTERNNET help page
num_epochs = 5000;


[Y, NErrors,W] = train_patternnet_no_regularizer(X,T1,num_epochs);

NErrors = length(find(round(Y)~=round(T)));

figure;
plotconfusion(T1,Y);
NErrors
[c,cm,ind,per] = confusion(T,Y)

% Confusion as fraction
T2 = cm'./sum(cm',1);

T3=T2(:,vec2ind(T));
[Y, NErrors,W] = train_patternnet_no_regularizer(X,T3,num_epochs);

