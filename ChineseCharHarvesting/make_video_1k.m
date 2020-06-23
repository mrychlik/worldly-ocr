%
% Some Fun: Making a video
% Demonstrate that the learnt weights contain
% Chinese characters
% NOTE: Run script1k.m before to create the data file
%
[~,~,Height,Width] = prepare_training_data;
load('best_weights_1k');

vidObj=VideoWriter('catscan_1k.avi','Motion JPEG AVI');
set(vidObj,'FrameRate',5);
open(vidObj);

figure('Position',[200,200,1024,768])
for r=1:size(W,1)
    imagesc(reshape(squeeze(W(r,2:end)),[Height,Width]));
    title(['Slice ', num2str(r)]);
    drawnow;
    currFrame = getframe(gcf);
    writeVideo(vidObj, getframe);
end
close(vidObj);