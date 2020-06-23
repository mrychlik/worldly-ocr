pfm = FontManagerSQLite;

BW_A = fm.get_char_image('A');
BW_B = fm.get_char_image('B');
BW_A_1 = fm.get_char_image('A');
BW_A_2 = fm.get_char_image('B');

figure;
subplot(1,2,1),imagesc(BW_A);
subplot(1,2,2),imagesc(BW_B);