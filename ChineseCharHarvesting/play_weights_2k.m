%
% Some Fun:
% Demonstrate that the learnt weights contain
% Chinese characters
%
[~,~,Height,Width] = prepare_training_data;
load('best_weights_2k');
for r=1:size(W,1)
    imagesc(reshape(squeeze(W(r,2:end)),[Height,Width]));
    drawnow;
    pause(0.3);
end