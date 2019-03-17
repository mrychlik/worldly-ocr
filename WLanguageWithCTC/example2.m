%
% An exploration of the Deep Learning framework.
%
% This script uses a custom classification layer
% which shows data passed from the softmax layer.
%
% NOTE: The loss is set to 0, so nothing useful happens in regard to training.
%
[XTrain, YTrain] = prepareDataTrain(1000, 32, 1);

numFeatures = 3;
numHiddenUnits = 32;
numClasses = 3;

ctcLayer = CTCLayer;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits,...
              'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    ctcLayer];


%% 'ExecutionEnvironment', 'cpu',...


options = trainingOptions('adam', ...
                          'ExecutionEnvironment', 'auto',...
                          'LearnRateDropPeriod',64, ...
                          'GradientThreshold',0.00001, ...
                          'LearnRateSchedule','piecewise', ...
                          'MiniBatchSize', 64,...
                          'InitialLearnRate',0.5, ...
                          'Verbose',1, ...
                          'Plots','training-progress');
%% Train
net = trainNetwork(XTrain,YTrain,layers,options);


