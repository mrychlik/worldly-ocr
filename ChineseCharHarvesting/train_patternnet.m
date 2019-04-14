function [Y,NErrors,W] = train_patternnet(X, T, num_epochs, minibatch_size)
% [Y,NERRORS,W] = TRAIN_PATTERNNET(X, T, NUM_EPOCHS, MINIBATCH_SIZE) trains
% a pattennet with H hidden neurons.
    if nargin < 3; num_epochs = 128; end
    if nargin < 4; minibatch_size = 64; end

    T = sparse(T);                      % One-hot encoding is really wasteful
    eta = 1e-1;                         % Stop if learning rate drops below
    alpha = 1e-1;                       % Regularizer constant

    assert(size(X,2) == size(T,2), ['Inconsistent number of samples in ' ...
                        'data and targets.']);

    assert(all(sum(T,1)==1),'Target columns must sum up to 1');
    D = size(X, 1);                     % Dimension of data
    N = size(X, 2);                     % Number of samples
    C = size(T, 1);                     % Number of  classes
    W = alpha * rand(C,D);              % Starting weihgts
    Gn = [];
    LearningHandle = figure;
    H = uicontrol('Style', 'PushButton', ...
                  'String', 'Break', ...
                  'Callback', 'delete(gcbf)');
    stop_me=false;
    for epoch = 1:num_epochs
        P=randperm(N);
        for b =1:minibatch_size:(N-1);
            % Pick a minibatch sample
            batch=P((b+1):min((b+minibatch_size),N));
            batch_len=length(batch);
            X1 = X(:,batch);
            T1 = T(:,batch);
            Y1 = softmax(W * X1);             % Compute activations
            E = T1 - Y1;                       
            gradLoss = -E * X1' + alpha * W;;
            W = W - eta * gradLoss;
            G = loss(W,Y1,T1,alpha) / batch_len; % Loss per sample
            Gn = [Gn,G];

            % Visualize  learning
            set(0, 'CurrentFigure', LearningHandle),
            semilogy(Gn,'-'), 
            title(['Learning (epoch: ',num2str(epoch),')']),
            drawnow;
            % Re-center the weights
            if mod(epoch, 100) == 0 
                W = W - mean(W,1);
            end;
            if ~ishandle(H)
                stop_me = true;
                break;
            end
        end
        if stop_me
            break;
        end
    end

    Y = softmax(W * X);               
    NErrors = length(find(round(Y)~=T));
    disp(['Number of errors: ',num2str(NErrors)]);

end

function [G] = loss(W,Y,T,alpha)
    G = cross_entropy(W,Y,T);
    G = G + alpha * sum(W * W','all');  % Regularize
end

function [Z] = cross_entropy(W,Y,T)
    Z = -sum(T .* log(Y+eps),'all');
end
