%
% File: make_book_strip.m
% Author: Marek Rychlik (rychlik@email.arizona.edu)
% 
% Script input: Book pages in directory 'Pages'
% Script output: Image file BookStrip.png
%
% This script converts lots of pages of the Chinese text to a single strip,
% stacking columns one above the other.  While not perfect, this process
% produces input (BookStrip.png) which could be processed through different
% algorithms (clustering, neural net, Tesseract) to decode the book, or
% produce a significant 'ground truth' for traditional Chinese.
%
pagedir='Pages';
speed=80;
pages=10:117;
%pages=49
B=[];                                   % Book as a strip
for page=pages;
    imfile=fullfile(pagedir, ['06061317.cn-000',...
                     sprintf('%03d',page),'.png']);
    I=imread(imfile);

    obj=Page(I,'PageNumber',page,'Display','on');
    clf;
    plot(obj.R(obj.P(:,1)),obj.T(obj.P(:,2)),'o-'),
    set(gca,'YLim',[-3,3]);
    drawnow,
    pause(1);

    %% Get the tall image of the text
    T=obj.tallImage;

    %% Fill in horizontal lines
    TT=imdilate(T,strel('line',40,0));

    %% Play tall image
    clf;
    subplot(1,3,1),imagesc(I),title(['Page ',num2str(page)]),
    for j=1:speed:(size(T,1)-600)
        subplot(1,3,2),imshow(TT(j:(j+600),:)),title(num2str(j)),
        subplot(1,3,3),imshow(T(j:(j+600),:)),title(num2str(j)),drawnow;    
    end
    if(size(T,2) > size(B,2))
        B=padarray(B,[0,size(T,2)-size(B,2)],0,'post');
    else
        T=padarray(T,[0,size(B,2)-size(T,2)],0,'post');
    end
    B=[B;T];
    display(size(B));
end
save('BookStrip.mat',B);
