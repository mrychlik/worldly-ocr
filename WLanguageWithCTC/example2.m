%
% An exploration of the Deep Learning framework.
%
% This script uses a custom classification layer
% which shows data passed from the softmax layer.
%
% NOTE: The loss is set to 0, so nothing useful happens in regard to training.
%
[XTrain, YTrain] = prepareDataTrain(1000, 6, 1);

numFeatures = size(XTrain{1},1);
numHiddenUnits = 8;
numClasses = length(categories(YTrain{1}));

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
    Y = YTest{j};
    Y = Y(Y~='_');
    Z = YPred{j};
    if length(Z) ~= length(Y) || ~all(B(Z) == Y)
        count = count + 1;
    end
end

Confusion = count / length(YPred);
Confusion