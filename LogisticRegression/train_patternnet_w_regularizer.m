function [Y,NErrors,W] = train_patternnet_w_regularizer(X, T, num_epochs)
    if nargin < 3; num_epochs=10000; end;
    min_eta = 1e-5;                     % Stop if learning rate drops below
    alpha = 0;                       % Regularizer constant

    assert(size(X,2) == size(T,2), ['Inconsistent number of samples in ' ...
                        'data and targets.']);

    assert(all((sum(T,1)-1) < eps),'Target rows must sum up to 1');
    D = size(X, 1);                     % Dimension of data
    N = size(X, 2);                     % Number of samples
    C = size(T, 1);                     % Number of  classes
    W = zeros([C, D]);                  % 0 Starting weihgts

    Y = softmax(W * X);                 % Compute activations
    %% Update gradient
    E = T - Y;
    DW = -E * X' - alpha * tanh(W);

    eta = 2*min_eta;          % Initial learning rate
    
    G = loss(W,Y,T,alpha)              % Test on the original sample
    Gn = [G];

    LearningHandle = figure;
    H = uicontrol('Style', 'PushButton', ...
                  'String', 'Break', ...
                  'Callback', 'delete(gcbf)');
    for epoch = 1:num_epochs
        if mod(epoch, 100)==0; disp(['Epoch: ',num2str(epoch)]); end

        % Update weights
        W_old = W;
        W = W - eta * DW;

        %% Update gradient
        DW_old = DW;
        Y = softmax(W * X);                % Compute activations
        E = T - Y;
        DW = -E * X' - alpha * tanh(W);

        G = loss(W,Y,T,alpha)          % Test on the original sample
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
        %     % Re-center the weights
        % if mod(epoch, 100) == 0 
        %     W = W - mean(W);
        % end;
        %pause(.1);
        if ~ishandle(H)
            break;
        end
    end

    NErrors = length(find(round(Y)~=round(T)));
    disp(['Number of errors: ',num2str(NErrors)]);

end

function [G] = loss(W,Y,T,alpha)
    G = cross_entropy(W,Y,T);
    G = G + alpha * sum(log(exp(W)+exp(-W)),'all');% Regularize
end

function [Z] = cross_entropy(W,Y,T)
    Z = -sum(T .* log(Y+eps),'all');
end
