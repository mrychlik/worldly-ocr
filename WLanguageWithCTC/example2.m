%
% An exploration of the Deep Learning framework.
%
% This script uses a custom classification layer
% which shows data passed from the softmax layer.
%
% NOTE: The loss is set to 0, so nothing useful happens in regard to training.
%
[XTrain, YTrain] = prepareDataTrain(1000, 16, 1);

numFeatures = 3;
numHiddenUnits = 32;
numClasses = 4;

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
                          'LearnRateDropPeriod',20, ...
                          'GradientThreshold',0.01, ...
                          'LearnRateSchedule','piecewise', ...
                          'MiniBatchSize', 48,...
                          'InitialLearnRate',0.01, ...
                          'Verbose',1, ...
                          'Plots','training-progress');
%% Train
net = trainNetwork(XTrain,YTrain,layers,options);


% Test prediction
[XTest, YTest] = prepareDataTrain;

[YPred, YScore] = classify(net, XTest, 'MiniBatchSize', 1);


count = 0;
for j=1:length(YPred)
    if ~all(YPred{j} == YTest{j})
        count = count + 1;
    end
end

Confusion = count / length(YPred);
Confusion