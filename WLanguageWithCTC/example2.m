%
% An exploration of the Deep Learning framework.
%
% This script uses a custom classification layer
% which shows data passed from the softmax layer.
%
% NOTE: The loss is set to 0, so nothing useful happens in regard to training.
%
[XTrain, YTrain] = prepareDataTrain(1000, 10, 1);

numFeatures = 3;
numHiddenUnits = 30;
numClasses = 3;

ctcLayer = CTCLayer;

layers = [ ...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits,...
                'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    ctcLayer];


%% 'ExecutionEnvironment', 'cpu',...


options = trainingOptions('adam', ...
                          'ExecutionEnvironment', 'auto',...
                          'LearnRateDropPeriod',10, ...
                          'GradientThreshold',0.00001, ...
                          'LearnRateSchedule','piecewise', ...
                          'MiniBatchSize', 64,...
                          'InitialLearnRate',0.5, ...
                          'Verbose',1, ...
                          'Plots','training-progress');
%% Train
net = trainNetwork(XTrain,YTrain,layers,options);


