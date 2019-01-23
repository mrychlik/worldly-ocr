function [Y,NErrors,W] = train_patternnet(X, T, num_epochs)
% NERRORS = TRAIN_PATTERNNET(X, T, NUM_EPOCHS)    trains
% a pattennet with H hidden neurons.
    min_eta = 1e-5;                     % Stop if learning rate drops below
    alpha = 1e-1;                       % Regularizer constant

    assert(size(X,1) == size(T,1), ['Inconsistent number of samples in ' ...
                        'data and targets.']);

    assert(all(sum(T,2)==1),'Target rows must sum up to 1');
    D = size(X, 2);                     % Dimension of data
    N = size(X, 1);                     % Number of samples
    C = size(T, 2);                     % Number of  classes

    SigmaW = (1 / (2 * alpha)) * eye(D * C);
    W = mvnrnd(zeros([1, D * C]), SigmaW);   % Starting weihgts
    W = reshape(W, [C, D]);

    Y = my_softmax(X * W');                % Compute activations
    %% Update gradient
    E = T - Y;
    DW = -E' * X + alpha * W;

    eta = 1 /(eps + norm(DW));          % Initial learning rate

    G = loss(W,Y,T,alpha);              % Test on the original sample
    Gn = [G];

    LearningHandle = figure;
    for epoch = 1:num_epochs
        if mod(epoch, 100)==0; disp(['Epoch: ',num2str(epoch)]); end

        % Update weights
        W_old = W;
        W = W - eta * DW;

        %% Update gradient
        DW_old = DW;
        Y = my_softmax(X * W');                % Compute activations
        E = T - Y;
        DW = -E' * X + alpha * W;

        G = loss(W,Y,T,alpha);          % Test on the original sample
        Gn = [Gn,G];

        % Adjust learning rate according to Barzilai-Borwein

        eta = ((W(:) - W_old(:))' * (DW(:) - DW_old(:))) ...
              ./ (eps + norm(DW(:) - DW_old(:))^2 );

        %  Limit the history to 100
        if length(Gn) == 101
            Gn = Gn(2:101);
        end

        if eta < min_eta
            disp('Learning rate threshold met, stopping...');        
            break;
        end


        % Visualize  learning
        if mod(epoch, 10) == 0 
            set(0, 'CurrentFigure', LearningHandle),
            plot(Gn,'-o'), 
            title(['Learning (epoch: ',num2str(epoch),')']),
            disp(['Learning rate: ',num2str(eta)]);
            drawnow;
        end
            % Re-center the weights
        if mod(epoch, 100) == 0 
            W = W - mean(W);
        end;
        %pause(.1);
    end

    NErrors = length(find(round(Y)~=T));
    disp(['Number of errors: ',num2str(NErrors)]);

end

function [G] = loss(W,Y,T,alpha)
    G = cross_entropy(W,Y,T);
    G = G + alpha * sum(W * W','all');% Regularize
end

function [Z] = cross_entropy(W,Y,T)
    Z = -sum(T .* log(Y+eps),'all');
end

function y = my_softmax(x)
% Y = MY_SOFTMAX(X) applies softmax to the rows of matrix X.
% It returns a matrix of the same size as X.

    y = softmax(x')';

    % Direct implementation:
    %    y = exp(x);
    %    s = sum(y, 2);
    %    y = y ./ s;
end

