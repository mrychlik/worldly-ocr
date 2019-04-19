classdef LogisticRegression
    
    properties
        X                               % Training data
        T                               % Target data
        Height                          % Digit height (pixels)
        Width                           % Digit width (pixels)
        Y                               % Network activation
        NErrors                         % Number of errors
        W                               % Weights
        eta                             % Learning rate
        epoch = 0                       % Epoch counter
        epoch_max;                      % Number of epochs to run
        losses = [];                    % List of loss values

        State = LogisticRegression.STATE_IDLE; % State of drawing
    end

    properties(Constant)
        app_name = 'MNISTDigitLearner' % This application name
        min_eta = 1e-5                  % Stop if learning rate drops below
        alpha = 1e-1                    % Regularizer constant
        epoch_increment = 100           % Number of epochs to add
        update_period = 10              % Update stats this often

        STATE_IDLE = 0                  % We are not hand-drawing a digit
        STATE_DRAWING = 1               % We are hand-drawing a digit
    end

    properties(Access=private)
        app                             % The GUI
        ImageHandle                     % Image of a hand-drawn digit
    end
    
    properties(Dependent)
        app_data_path                   % Where the app data is
    end
    
    methods
        function path = get.app_data_path(this)
            if isdeployed
                % We will find the files in the 'application' folder
                path = '';
            else
                % We're running within MATLAB, either as a MATLAB app,
                % or from a copy of the current folder. If we're running
                % as a MATLAB app, we need to get the application folder
                % by using matlab.apputil class.
                apps = matlab.apputil.getInstalledAppInfo;
                ind=find(cellfun(@(x)strcmp(x,this.app_name),{apps.name}));
                if isempty(ind)
                    path = '.';             % Current directory
                else
                    path = apps(ind).location; % This app is installed, its path
                end
            end
        end


        function print_app_info(this)
        %PRINT_APP_INFO prints information about the app environment
            if isdeployed
                % Print deployment information
                fprintf('Running %s as a standalone application.\n',this.app_name);
                fprintf('Application files are in: %s\n', ctfroot);
                fprintf('MATLAB runtime version is: %d\n', mcrversion);
            else
                % 
                fprintf('Running %s a MATLAB app.\n',this.app_name);
                fprintf('MATLAB version: %s\n', version);
                apps = matlab.apputil.getInstalledAppInfo;
                ind=find(cellfun(@(x)strcmp(x,this.app_name),{apps.name}));
                if isempty(ind)
                    path = '.';             % Current directory
                else
                    path = apps(ind).location; % This app is installed, its path
                end
                fprintf('App data folder is %s\n',path);
            end
        end


        function this = LogisticRegression(app)
            this.app = app;
            this.print_app_info;
            this.clear_digit;
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

            if ~continuing || isempty(this.W)
                this.epoch = 0;
                SigmaW = (1 / (2 * this.alpha)) * eye(D * C);
                this.W = mvnrnd(zeros([1, D * C]), SigmaW);   % Starting weihgts
                this.W = reshape(this.W, [C, D]);
            end
            
            %% Update gradient
            this.Y = softmax(this.W * this.X);% Compute activations
            E = this.T - this.Y;
            DW = -E * this.X' + this.alpha * this.W;

            if ~continuing
                this.eta = 1 /(eps + norm(DW));          % Initial learning rate
                loss = this.loss;       % Test on the original sample
                this.losses = [loss];
                this.epoch_max = this.epoch_increment;
            else
                this.epoch_max = this.epoch_max + this.epoch_increment;
            end

            while this.epoch < this.epoch_max
                this.epoch = this.epoch + 1;
                % Update weights
                W_old = this.W;
                this.W = this.W - this.eta * DW;

                %% Update gradient
                DW_old = DW;
                this.Y = softmax(this.W * this.X);                % Compute activations
                E = this.T - this.Y;
                DW = -E * this.X' + this.alpha * this.W;

                loss = this.loss;% Test on the original sample
                this.losses = [this.losses,loss];

                % Adjust learning rate according to Barzilai-Borwein
                this.eta = ((this.W(:) - W_old(:))' * (DW(:) - DW_old(:))) ...
                    ./ (eps + norm(DW(:) - DW_old(:))^2 );

                % Visualize  learning
                ax = this.app.UIAxes;
                if mod(this.epoch, this.update_period) == 0 
                    semilogy(ax, this.losses,'-'), 
                    title(ax,['Learning (epoch: ',num2str(this.epoch),')']),
                    %disp(['Learning rate: ',num2str(this.eta)]);
                    drawnow;
                    % Update error stats
                    this.app.LearningRateEditField.Value = this.eta;
                    this.NErrors = length(find(round(this.Y)~=this.T));
                    this.app.NumberOfErrorsEditField.Value = this.NErrors;
                end
                % Re-center the weights
                if mod(this.epoch, 100) == 0 
                    this.W = this.W - mean(this.W);
                end;
                %pause(.1);
            end
            plot_confusion(this);
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
            data_file = fullfile(this.app_data_path, 'digit_data.mat');
            load(data_file);

            digits = this.app.digits;

            % Digits to analyze
            num_digits = length(digits);

            this.app.DigitViewerPanel.AutoResizeChildren = 'off';
            g = ceil(sqrt(num_digits));
            for j=1:num_digits
                Digit{j}=I(T==digits(j),:,:)./255;
                ax = subplot(g,g,j,'Parent',this.app.DigitViewerPanel);
                imagesc(ax,squeeze(Digit{j}(1,:,:))');
                title(ax,['Class ', num2str(j)]);
            end
            drawnow;

            % Height and width of images
            this.Height = size(Digit{1},2);
            this.Width = size(Digit{1},3);

            % Linearized images
            X0 = [];
            T0 = [];
            for j=1:num_digits
                LinDigit = reshape(Digit{j}, [size(Digit{j},1), this.Width * this.Height]);
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

        function plot_confusion(this)
            if isempty(this.Y) 
                return;
            end
            [c,cm] = confusion(this.T,this.Y);
            labels = this.app.DigitPickerListBox.Value;
            panel = this.app.ConfusionMatrixPanel;
            panel.AutoResizeChildren = 'off';
            ax = subplot(1,1,1,'Parent',panel);
            plotConfMat(ax,cm,labels);
        end

        function [G] = loss(this)
            G = this.cross_entropy;
            G = G + this.alpha * sum(this.W .^2,'all');% Regularize
        end

        function [Z] = cross_entropy(this)
            Z = -sum(this.T .* log(this.Y+eps),'all');
        end

        function this = plot_mean_digit(this, digit)
        % MEAN_DIGIT_IMAGE get mean image of a digit
            if nargin < 2
                digit=this.app.digit;
            end
            % Find digit index in the current training digits
            digit_idx = find(digit==this.app.digits,1);
            % Find indices which label is correct
            idx = find(this.T(digit_idx,:));
            mean_digit = reshape(mean(this.X(:,idx),2), [this.Height,this.Width])'; 
            this.ImageHandle = imagesc(this.app.UIAxes2, mean_digit);
            colormap(this.app.UIAxes2,1-gray .* this.app.hint_intensity);
        end

        function this = clear_digit(this)
        %this.ImageHandle.CData = zeros(this.Height,this.Width);
        %drawnow;
        end

        function value = hit(this, event)
            disp(event.HitObject);
            value = event.HitObject == this.ImageHandle;
            if value; disp('Hit'); end
        end

        function this = WindowEventFcn(this, event)
            fprintf('Event: %s, State: %d\n', event.EventName, this.State);
            display(event.HitObject);
            switch event.EventName,
              case 'WindowMousePress',
                fprintf('MousePress, state %d\n', this.State);
                % if ~this.hit(event) || ( this.State ~= LogisticRegression.STATE_IDLE ...
                %                          )
                %     return
                % end
                this = this.clear_digit;

                x = round(event.IntersectionPoint(1));
                y = round(event.IntersectionPoint(2));
                disp(x); disp(y);
                if ~( 1 <= x && x <= this.Width && 1 <= y && y <= this.Height )
                    return;
                else
                    this.State = LogisticRegression.STATE_DRAWING;
                end
                fprintf('New state %d\n', this.State);


              case 'WindowMouseRelease',


                fprintf('MouseRelease, state %d\n', this.State);
                % if ~this.hit(event) || ( this.State ~= ...
                %                          LogisticRegression.STATE_DRAWING )
                %     return;
                % end

                x = round(event.IntersectionPoint(1));
                y = round(event.IntersectionPoint(2));
                disp(x); disp(y);
                if ~( 1 <= x && x <= this.Width && 1 <= y && y <= this.Height )
                    return;
                else
                    this.State = LogisticRegression.STATE_IDLE;
                end

              case 'WindowMouseMotion',

                fprintf('Button moved, state %d\n', this.State);
                % if ~this.hit(event) || ( this.State ~= ...
                %                          LogisticRegression.STATE_DRAWING )
                %     return;
                % end
                x = round(event.IntersectionPoint(1));
                y = round(event.IntersectionPoint(2));
                disp(x); disp(y);
                if ~( 1 <= x && x <= this.Width && 1 <= y && y <= this.Height )
                    return;
                else
                    display('Drawing');
                    this.ImageHandle.CData(y,x)= 255;
                    drawnow;
                end
            end
        end
    end
end