%
% File: find_occurrences.m
% Author: Marek Rychlik (rychlik@email.arizona.edu)
% 
% Script input: 1) Book pages in directory 'Pages'
%               2) Book characters in structure CharSeq (made_by partition_book_into_chars)
%               
% Script output: Graphical
%
% This script finds occurrences of a particular character in pages of the book
%


pagedir='Pages';

%% Illustrate the method to determine the shift
%% of an image in 2 dimensions, using FFT.
partition_book_into_chars;

Padding=[6,6];

%% Pick a reference character
%RefChar=CharSeq(68).bwimage; %Most frequent, very robust
%RefChar=CharSeq(25).bwimage;
%RefChar=CharSeq(9).bwimage;
%RefChar=CharSeq(8).bwimage;
%RefChar=CharSeq(39).bwimage;
%RefChar=CharSeq(49).bwimage;
%RefChar=CharSeq(11).bwimage;
%RefChar=CharSeq(26).bwimage;
%RefChar=CharSeq(33).bwimage;
%RefChar=CharSeq(53).bwimage;
%RefChar=CharSeq(14).bwimage;
%RefChar=CharSeq(15).bwimage;
%RefChar=CharSeq(19).bwimage;
%RefChar=CharSeq(27).bwimage;
%RefChar=CharSeq(31).bwimage;
%RefChar=CharSeq(32).bwimage;
%RefChar=CharSeq(43).bwimage;
%RefChar=CharSeq(47).bwimage;
%RefChar=CharSeq(48).bwimage;
%RefChar=CharSeq(50).bwimage;
%RefChar=CharSeq(51).bwimage;
%RefChar=CharSeq(52).bwimage;
%RefChar=CharSeq(54).bwimage;
%RefChar=CharSeq(55).bwimage;
%RefChar=CharSeq(62).bwimage;
%RefChar=CharSeq(64).bwimage;
%RefChar=CharSeq(66).bwimage;
%RefChar=CharSeq(71).bwimage;
%RefChar=CharSeq(73).bwimage;            % Reliable
%RefChar=CharSeq(77).bwimage;            % Reliable
%RefChar=CharSeq(81).bwimage;            % Interesting
%RefChar=CharSeq(83).bwimage;            % Reliable, parts
%RefChar=CharSeq(98).bwimage;            % Connected, complex, rare
%RefChar=CharSeq(107).bwimage;           % Connected, reliable
RefChar=CharSeq(135).bwimage;           % 2 early occurr.
%RefChar=CharSeq(220).bwimage;           % Reliable?
%RefChar=CharSeq(228).bwimage;           
%RefChar=CharSeq(235).bwimage;           
%RefChar=CharSeq(237).bwimage;           % Connected, complex, robust
%RefChar=CharSeq(279).bwimage;           % Connected, robust
%RefChar=CharSeq(287).bwimage;           % Robust, nearly connected
%RefChar=CharSeq(324).bwimage;           % Connected, robust

RefChar=im2bw(RefChar);
RefChar=padarray(RefChar,Padding,0,'both');
subplot(1,3,1),imshow(RefChar),
title(sprintf('Size: [%d,%d]',size(RefChar,1),size(RefChar,2)));

RunningCount=0;
for page=10:117;
    set(gcf,'Name',['Page ', num2str(page)],'NumberTitle','off');
    imfile=fullfile(pagedir, ['06061317.cn-000',sprintf('%03d',page),'.png']);
    I=imread(imfile);
    % Work with negative
    I=255-I;
    I=im2bw(I);
    [Where,RunningCount]=find_char_in_image(RefChar,I,RunningCount);
endo