%
% File: make_book_strip.m
% Author: Marek Rychlik (rychlik@email.arizona.edu)
%
% Script Inputs: image file BookStrip.png (output of make_book_strip)
% Script Output: structure CharSeq, containing character objects
%
% This script takes the image BookStrip.png which contains 
% stacked columns of all pages, and it outputs the sequence
% of characters contained in the image.
%

Display='off';

savefile=fullfile('.','Cache','CharSeq.mat');

if exist(savefile,'file') 
    load(savefile)
else 
    B=imread('BookStrip.png');
    P=sum(B,2)>.3.*max(B(:)).*size(B,2);
    Q=diff([0;P]);
    Up=Q==1;
    Down=Q==-1;
    hold on,
    plot(Up(1:1000),'Color','red'),
    plot(Down(1:1000),'Color','blue'),
    hold off;
    pause(2);

    cnt=1;
    for r=1:size(B,1)
        if Up(r)==1 
            char_start=r;
        elseif Down(r)==1
            char_end=r;
            Char=B(char_start:char_end,:);
            Char=imautocrop(Char,'Direction','horizontal');
            if strcmp(Display,'on')
                hold on,
                clf,
                imshow(imresize(Char,5)),
                title(['Character count ', num2str(cnt), ', ', ...
                       num2str(char_start),'-',num2str(char_end)]),
                colormap hot,
                hold off,
                drawnow;
            else
                display(cnt);
            end
            CharSeqRough(cnt).bwimage=Char;
            cnt=cnt+1;
        end
    end
    char_sizes=cell2mat(arrayfun(@(b)size(b.bwimage)',CharSeqRough,...
                                 'UniformOutput', false))';
    mean_size=mean(char_sizes);

    mean_height=mean_size(1);
    mean_width=mean_size(2);    

    CharSeq=[];
    cnt=1;
    for rough_cnt=1:numel(CharSeqRough)
        Char=CharSeqRough(rough_cnt).bwimage;
        k=round(size(Char,1)./mean_height);
        CharSeqRough(rough_cnt).split=k;
        if k > 1
            hold on,
            subplot(1,k+1,1),imshow(imresize(Char,5)),
            title(['Rough character to split: ',num2str(rough_cnt)]),
            for l=0:(k-1)
                start_row=floor((l./k).*size(Char,1)) + 1;
                end_row=floor(((l+1)./k).*size(Char,1));
                CharPart=Char( start_row:end_row,:);
                subplot(1,k+1,l+2),
                imshow(imresize(CharPart,5)),
                title(['Character part: ', num2str(l)]);
                CharSeq(cnt).bwimage=CharPart;
                CharSeq(cnt).rough_idx=rough_cnt;
                cnt=cnt+1;
            end
            hold off,
            drawnow;
        else
            CharSeq(cnt).bwimage=Char;
            CharSeq(cnt).rough_idx=rough_cnt;            
            cnt=cnt+1;
        end
    end    
    save(savefile,'CharSeqRough','CharSeq');
end

