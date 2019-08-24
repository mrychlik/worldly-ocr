% Study feature (fixed pixel) distribution

digit0 = 0;
digit1 = 1;
digit2 = 2;
digit3 = 3;
[X,T] = prepare_training_data(digit0,digit1,digit2,digit3);
% Matlab expects samples in columns and T to be a row vector

% Find training data dimensions
[D,N] = size(X);
[C,~]=size(T);

L = vec2ind(T);
for c=1:C
    for d=1:D
        hist(X(d,L==c),20);
        title(sprintf('d=%d, c=%d',d,c));
        pause(.2);
    end
end




