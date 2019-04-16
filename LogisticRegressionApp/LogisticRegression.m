classdef LogisticRegression
    
    properties
        X                               % Training data
        T                               % Target data
        Y                               % Network activation
        NErrors                         % Number of errors
        W                               % Weights
        eta                             % Learning rate
        epoch = 0                       % Epoch counter
        epoch_max;                      % Number of epochs to run
    end

    properties(Constant)
        min_eta = 1e-5                  % Stop if learning rate drops below
        alpha = 1e-1                    % Regularizer constant
        epoch_increment = 1000;         % When manually continuing,
                                        % increment epochs by this number
    end

    properties(Access=private)
        app
    end
    
    
    methods
        function this = LogisticRegression(app)
            this.app = app;
        end

        function this = train(this,continuing)
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
            if nargin < 2; continuing = false; end;

            assert(size(this.X,2) == size(this.T,2), ['Inconsistent number of samples in ' ...
                                'data and targets.']);

            assert(all(sum(this.T,1)==1),'Target rows must sum up to 1');
            D = size(this.X, 1);                     % Dimension of data
            N = size(this.X, 2);                     % Number of samples
            C = size(this.T, 1);                     % Number of  classes

            if ~continuing
                SigmaW = (1 / (2 * this.alpha)) * eye(D * C);
                this.W = mvnrnd(zeros([1, D * C]), SigmaW);   % Starting weihgts
                this.W = reshape(this.W, [C, D]);
                this.epoch_max = this.epoch_increment;
                this.epoch = 0;
            else
                this.epoch_max = this.epoch_max + this.epoch_increment;
            end

            this.Y = softmax(this.W * this.X);                 % Compute activations
            %% Update gradient
            E = this.T - this.Y;
            DW = -E * this.X' + this.alpha * this.W;

            this.eta = 1 /(eps + norm(DW));          % Initial learning rate

            G = this.loss;       % Test on the original sample
            Gn = [G];

            while this.epoch <= this.epoch_max
                % Update weights
                W_old = this.W;
                this.W = this.W - this.eta * DW;

                %% Update gradient
                DW_old = DW;
                this.Y = softmax(this.W * this.X);                % Compute activations
                E = this.T - this.Y;
                DW = -E * this.X' + this.alpha * this.W;

                G = this.loss;% Test on the original sample
                Gn = [Gn,G];

                % Adjust learning rate according to Barzilai-Borwein
                this.eta = ((this.W(:) - W_old(:))' * (DW(:) - DW_old(:))) ...
                    ./ (eps + norm(DW(:) - DW_old(:))^2 );

                % Visualize  learning
                ax = this.app.UIAxes;
                if mod(this.epoch, 10) == 0 
                    semilogy(ax, Gn,'-'), 
                    title(ax,['Learning (epoch: ',num2str(epoch),')']),
                    disp(['Learning rate: ',num2str(this.eta)]);
                    drawnow;
                    % Update error stats
                    this.app.LearningRateEditField = this.eta;
                    this.NErrors = length(find(round(this.Y)~=this.T));
                    this.app.NumberOfErrorsEditField.Value = this.NErrors;
                end
                % Re-center the weights
                if mod(this.epoch, 100) == 0 
                    this.W = this.W - mean(this.W);
                end;
                %pause(.1);
            end
        end

        function this = prepare_training_data(this)
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

            digits = this.app.digits;

            % Digits to analyze
            num_digits = length(digits);

            this.app.DigitViewerPanel.AutoResizeChildren = 'off';
            g = ceil(sqrt(num_digits));
            for j=1:num_digits
                Digit{j}=I(T==digits(j),:,:)./255;
                ax = subplot(g,g,j,'Parent',this.app.DigitViewerPanel),
                imagesc(ax,squeeze(Digit{j}(1,:,:))'),
                title(ax,['Class ', num2str(j)]);
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
            this.X = X0(P,:)';
            this.T = T0(P,:)';
        end

        function [G] = loss(this)
            G = this.cross_entropy;
            G = G + this.alpha * sum(this.W .^2,'all');% Regularize
        end

        function [Z] = cross_entropy(this)
            Z = -sum(this.T .* log(this.Y+eps),'all');
        end

    end
end