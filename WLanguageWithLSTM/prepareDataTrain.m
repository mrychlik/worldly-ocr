function [XTrain, YTrain] = prepareDataTrain

N = 1000;
L = 3;
X = cell(N,1);
max_stretch = 1;

% Map random strings to W-language
for j = 1:N
    String{j} = randsample('XOZ', L, true);
    [X, Y] = W(String{j}, max_stretch);
    XTrain{j} = X';
    YTrain{j} = categorical(cellstr(Y))';
end


