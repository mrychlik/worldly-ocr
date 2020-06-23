%%
% Address of the folder the image is located, and reading the figure
clc;clear
dirpath='Pages';
imgname='page-14.ppm';
imgfile=fullfile(dirpath,imgname);
I=imread(imgfile);
figure
imshow(I);
%% Applying different methods
Thres=0.2;
BW1=BWThreshold(I,1,Thres);
BW2=BWThreshold(I,2,Thres);
BW3=BWThreshold(I,3,Thres);
BW4=BWThreshold(I,4,Thres);
%% figurues
n=4
figure;subplot(1,n,1);
imshow(BW1);title("0.2")
subplot(1,n,2)
imshow(BW2);title("Global Otsu Method")
subplot(1,n,3)
imshow(BW3);title("Adaptive Filter, Mean")
subplot(1,n,4)
imshow(BW4);title("Adaptive Filter, Gaussian")