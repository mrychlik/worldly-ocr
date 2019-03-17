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
% published at <https://arxiv.org/abs/1806.09038>. The underscore '_' means
% that there was no emission at the corresponding time point.
% 
nargchk(0, 3, nargin);

if nargin < 1; num_samples = 1000; end;
if nargin < 2; sample_length = 5; end;
if nargin < 3; max_stretch = 1; end;
    
X = cell(num_samples, 1);

valueset = {'X','O','_','.'};

% Map random strings to W-language
for j = 1:num_samples
    String{j} = randsample('XO_', sample_length, true);
    [X, Y] = W(String{j}, max_stretch);
    XTrain{j} = X';
    len=length(X);
    Y = Y(Y~='_');
    P = repmat('_',len-length(Y),1);
    YTrain{j} = categorical(cellstr([Y;P]),valueset)';
end


% Padd to the oritinal length with periods ('certain endmark' symbols).
% NOTE: MATLAB does not allow targets to have variable length
% as they are delivered to the classification layer as matrices
% of the same size as inputs. Therefore, we padd all vectors to
% the same length.


% Maximum time length of the inputs
% S=max(cellfun(@(x)size(x,2),XTrain));
% D=size(XTrain{1},1);
% for j = 1:num_samples
%     X=XTrain{j};
%     P=zeros([D,S-size(X,2)],'single');
%     X=padarray(X,[1,0],0,'post');
%     P=padarray(P,[1,0],1,'post');
%     XTrain{j} = [X,P];
% end

% % Maximum length of a label
% M = max(cellfun(@length,YTrain));
% assert(M <= S);
% for j = 1:num_samples
%     Y=YTrain{j};
%     P=repmat('.',S-length(Y),1);
%     YTrain{j} = categorical(cellstr([Y;P]),valueset)';
% end
