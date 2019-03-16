%
% An exploration of the Deep Learning framework.
%
% This script uses a custom classification layer
% which shows data passed from the softmax layer.
%
% NOTE: The loss is set to 0, so nothing useful happens in regard to training.
%
[XTrain, YTrain] = prepareDataTrain;

numFeatures = 3;
numHiddenUnits = 9;
numClasses = 3;

ctcLayer = CTCLayer;

layers = [ ...
    sequenceInputLayer(numFeatures)
    % bilstmLayer(numHiddenUnits,...
    %             'OutputMode','sequence',...
    %             'GateActivationFunction', 'sigmoid')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    ctcLayer];


%% 'ExecutionEnvironment', 'cpu',...


options = trainingOptions('adam', ...
                          'ExecutionEnvironment', 'auto',...
                          'LearnRateDropPeriod',20, ...
                          'GradientThreshold',0, ...
                          'LearnRateSchedule','piecewise', ...
                          'MiniBatchSize', 8,...
                          'InitialLearnRate',0.01, ...
                          'Verbose',0, ...
                          'Plots','training-progress');
%% Train
net = trainNetwork(XTrain,YTrain,layers,options);


