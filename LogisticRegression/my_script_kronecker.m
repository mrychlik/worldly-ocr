% This script tests the new regularization method

digit0 = 0;
digit1 = 1;
digit2 = 2;
digit3 = 3;
[X,T] = prepare_training_data(digit0,digit1,digit2,digit3);
% Matlab expects samples in columns and T to be a row vector

% Find training data dimensions
[D,N] = size(X);
[C,~]=size(T);

% The matrix A such that the stacked activations U are computed
% by multiplying stacked input data:
%
%                   u = A * w
%
% Note that the operator vec which stacks matrices is simply (W is a
% C-by-D matrix):
%         w = vec(W) = W(:)
%         W = vec^(-1)(w) = reshape(w,[C,D]);
%         U = W * X
%         u = vec(U) = U(:);
%         U = vec^(-1)(u) = reshape(u,[D,N])
%
A=sparse(kron(X',eye(C)));

% Labels. L(n) is the index of the n-th label, n=1,2,...,N. L(n) is the
% index of the digit (it follows that it is *not* the digit but an index
% by 1 more than the digit.
L=vec2ind(T);

spy(A);

% Straight from PATTERNNET help page
num_epochs = 5000;
[Y, NErrors,W] = train_patternnet_w_regularizer(X,T,num_epochs);

figure;
plotconfusion(T,Y);
NErrors


