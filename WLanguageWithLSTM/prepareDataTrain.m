function [XTrain, YTrain] = prepareDataTrain(num_samples,sample_length, max_stretch)
% Create a trainint dataset in W-language
%  [XTRAIN, YTRAIN] = PREPAREDATATRAIN outputs:
%     XTRAIN - a cell array of L-by-3 matrices
% 
nargchk(0, 3)
if nargin < 1; num_samples = 1000; end
if nargin < 2; sample_length = 3;
if nargin < 3; max_stretch = 1;
    
X = cell(num_samples, 1);


% Map random strings to W-language
for j = 1:N
    String{j} = randsample('XOZ', L, true);
    [X, Y] = W(String{j}, max_stretch);
    XTrain{j} = X';
    YTrain{j} = categorical(cellstr(Y))';
end


