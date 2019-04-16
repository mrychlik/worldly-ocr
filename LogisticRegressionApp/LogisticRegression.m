classdef LogisticRegression
    
    properties
        X                               % Training data
        T                               % Target data
        num_epochs=1000                 % Number of epochs
    end

    properties(Access=private)
        app;
    end
    
    
    methods
        function this = LogisticRegression(app)
            this.app = app;
        end

        function train(this, app)
            [Y,NErrors,W] = train_patternnet(this,num_epochs);
        end

        function [Y,NErrors,W] = train_patternnet(X, T, num_epochs)
        %TRAIN_PATTERNNET trains a logistic regression network
        % [Y, NERRORS,W] = TRAIN_PATTERNNET(X, T, NUM_EPOCHS)    trains
        % a pattennet (logistic regression network) to recognize
        % patterns, which are columns of X, a D-by-N matrix.
        % The targets T is C-by-N, with each column being a probability
        % distribution of the patterns belonging to each of the C classes.
        % Often T(:,J) the column is the one-hot encoded true label of the 
        % pattern X(:,J). Note that the iteration can be stopped
        % at any time, by pressing the button in the left-lower corner 
        % of the plot, labeled 'BREAK'.
        %
        % The algorithm uses batch processing, whereby every sample is
        % included in the gradient computation in each epoch. The maximum number
        % of epochs can be specified by the argument NUM_EPOCHS (default: 10^4).
            if nargin < 3; num_epochs=10000; end;
            min_eta = 1e-5;                     % Stop if learning rate drops below
            alpha = 1e-1;                       % Regularizer constant

            assert(size(X,2) == size(T,2), ['Inconsistent number of samples in ' ...
                                'data and targets.']);

            assert(all(sum(T,1)==1),'Target rows must sum up to 1');
            D = size(X, 1);                     % Dimension of data
            N = size(X, 2);                     % Number of samples
            C = size(T, 1);                     % Number of  classes

            SigmaW = (1 / (2 * alpha)) * eye(D * C);
            W = mvnrnd(zeros([1, D * C]), SigmaW);   % Starting weihgts
            W = reshape(W, [C, D]);

            Y = softmax(W * X);                 % Compute activations
            %% Update gradient
            E = T - Y;
            DW = -E * X' + alpha * W;

            eta = 1 /(eps + norm(DW));          % Initial learning rate

            G = LogisticRegression.loss(W,Y,T,alpha);              % Test on the original sample
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
                DW = -E * X' + alpha * W;

                G = LogisticRegression.loss(W,Y,T,alpha);% Test on the original sample
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
                if ~ishandle(H)
                    break;
                end
            end

            NErrors = length(find(round(Y)~=T));
            disp(['Number of errors: ',num2str(NErrors)]);

        end
    end


    methods(Static)
        function [G] = loss(W,Y,T,alpha)
            G = LogisticRegression.cross_entropy(W,Y,T);
            G = G + alpha * sum(W .^2,'all');% Regularize
        end

        function [Z] = cross_entropy(W,Y,T)
            Z = -sum(T .* log(Y+eps),'all');
        end

        function [X,T,H,W] = prepare_training_data(digits)
        %PREPARE_TRAINING_DATA returns MNIST data prepared for training
        % [X,T,H,W] = PREPARE_TRAINING_DATA(D1,D2,...,DK) returns X, which is a
        % 784-by-N matrix, where N is the number of digit images. The arguments
        % D1, D2, ..., DK are the digit labels (a subset of 0, 1, ..., 9).
        % X contains linearized images. T is K-by-N matrix of one-hot encoded
        % labels for digit data.
        %
        % It should be noted that we can retrieve each digit image in the following manner:
        %
        %      [X,T] = prepare_training_data(0,1,2,3);
        %      n = 17;
        %      I=reshape(X(:,n),28,28)';
        %      imshow(I);
        %
        % This will give us the 17-th digit of the dataset, which happens to be a
        % rendition of digit '2'. 
        %
        % Transposing is necessary to get the vertical digit, else is a digit on
        % its side.

            data_file=fullfile('.','digit_data.mat');
            load(data_file);

            % Digits to analyze
            num_digits = length(digits);

            clf;
            for j=1:num_digits
                Digit{j}=I(T==digits(j),:,:)./255;
                subplot(1,num_digits,j), imagesc(squeeze(Digit{j}(1,:,:))'),
                title(['Class ', num2str(j)]);
            end
            drawnow;

            % Height and width of images
            H = size(Digit{1},2);
            W = size(Digit{1},3);

            % Linearized images
            X0 = [];
            T0 = [];
            for j=1:num_digits
                LinDigit = reshape(Digit{j}, [size(Digit{j},1), W * H]);
                X0 = [X0; LinDigit];
                T1 = zeros([size(LinDigit, 1),num_digits]);
                T1(:,j) = ones([size(LinDigit, 1),1]);
                T0 = [T0; T1];
            end

            % Combined samples

            N = size(X0,1);
            P = randperm(N);
            % Combined labels

            % Permuted combined samples and labels
            X = X0(P,:)';
            T = T0(P,:)';
        end
    end
end