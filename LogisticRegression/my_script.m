digit0 = 0;
digit1 = 1;
digit2 = 2;
digit3 = 3;
[X,T] = prepare_training_data(digit0,digit1,digit2,digit3);
% Matlab expects samples in columns and T to be a row vector


% Insert a row of 1's
X = [ones([1,size(X,2)]);X];

% Regularize T
[D,N] = size(X);
[C,~]=size(T);

T0=1/C*ones(C,1)*ones(1,N);
t=.984;
T=(1-t)*T0+t*T;

% Straight from PATTERNNET help page
num_epochs = 5000;
[Y, NErrors] = train_patternnet(X,T,num_epochs);

figure;
plotconfusion(T,Y);
NErrors