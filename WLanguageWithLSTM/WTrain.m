% load WLangTrain;
[XTrain, YTrain] = prepareDataTrain;

numFeatures = 3;
numHiddenUnits = 9;
numClasses = 3;

layers = [ ...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits,...
                'OutputMode','sequence',...
                'GateActivationFunction', 'sigmoid')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];


%% 'ExecutionEnvironment', 'cpu',...


options = trainingOptions('adam', ...
                          'ExecutionEnvironment', 'auto',...
                          'LearnRateDropPeriod',20, ...
                          'GradientThreshold',1, ...
                          'LearnRateSchedule','piecewise', ...
                          'MiniBatchSize', 50,...
                          'InitialLearnRate',0.01, ...
                          'Verbose',0, ...
                          'Plots','training-progress');

net = trainNetwork(XTrain,YTrain,layers,options);


% Test prediction
[XTest, YTest] = prepareDataTrain;

YPred = classify(net, XTest, 'MiniBatchSize', 1);


count = 0;
for j=1:length(YPred)
    if ~all(YPred{j} == YTest{j})
        count = count + 1;
    end
end

Confusion = count / length(YPred);
Confusion