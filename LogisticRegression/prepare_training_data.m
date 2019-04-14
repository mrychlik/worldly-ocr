function [X,T,H,W] = prepare_training_data(varargin)
%PREPARE_TRAINING_DATA returns MNIST data prepared for training
% [X,T,H,W] = PREPARE_TRAINING_DATA(D1,D2,...,DK) returns X, which is a
% 784-by-N matrix, where N is the number of digit images. The arguments
% D1, D2, ..., DK are the digit labels (a subset of 0, 1, ..., 9).
% X contains linearized images. T is K-by-N matrix of one-hot encoded
% labels for digit data.
% It should be noted that we can retrieve each digit image in this manner:
%
%      n = 17;
%      I=reshape(X(:,n),28,28)';
%      imshow(I)
%
% Transposing is necessary to get the vertical digit, else is a digit on
% its side.

data_file=fullfile('.','digit_data.mat');
load(data_file);

% Digits to analyze
digits = [varargin{:}];
num_digits = length(digits);

clf;
for j=1:num_digits
    Digit{j}=I(T==digits(j),:,:)./255;
    subplot(1,num_digits,j), imagesc(squeeze(Digit{j}(1,:,:))'),
    title(['Class ', num2str(j)]);
end
drawnow;

% Height and width of images
H = size(Digit{1},2);
W = size(Digit{1},3);

% Linearized images
X0 = [];
T0 = [];
for j=1:num_digits
    LinDigit = reshape(Digit{j}, [size(Digit{j},1), W * H]);
    X0 = [X0; LinDigit];
    T1 = zeros([size(LinDigit, 1),num_digits]);
    T1(:,j) = ones([size(LinDigit, 1),1]);
    T0 = [T0; T1];
end

% Combined samples

N = size(X0,1);
P = randperm(N);
% Combined labels

% Permuted combined samples and labels
X = X0(P,:)';
T = T0(P,:)';
