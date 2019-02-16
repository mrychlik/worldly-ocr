load xbox;
[A,H,V,D] = haart2(xbox);
subplot(2,1,1)
imagesc(D{1})
title('Diagonal Level-1 Details');
subplot(2,1,2)
imagesc(H{1})
title('Horizontal Level 1 Details');