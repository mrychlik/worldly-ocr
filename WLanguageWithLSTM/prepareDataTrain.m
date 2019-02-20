function [XTrain, YTrain] = prepareDataTrain(num_samples,sample_length, max_stretch)
% Create a trainint dataset in W-language
%  [XTRAIN, YTRAIN] = PREPAREDATATRAIN(NUM_SAMPLES,SAMPLE_LENGTH, MAX_STRETCH) outputs:
%     XTRAIN - a cell array of NUM_SAMPLES SAMPLE_LENGTH-by-3 matrices of 0-1;
%     YTRAIN - a cell array of NUM_SAMPLES strings of length
%              SAMPLE_LENGTH, with characters in the set {'X','O','_'}
%
%  The YTRAIN provides the responses to patterns in XTRAIN, which are the 
%  decoded strings of the W-language, emitted as per the algorithm
%  described in the paper 
%
%      Deductron - A Recurrent Neural Network
%
% published at https://arxiv.org/abs/1806.09038. The underscore '_' means
% that there was no emission at the corresponding time point.
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


