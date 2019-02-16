if ~exist('cropped','var')
    load('cropped.mat')
end
transpose=false;                         % Work with negative

% Plot grid size
m = 5;					% Number of rows
n = 8;					% number of columns
nimages = m*n;
p = 1;


clf;
for idx=1:nsamples
  I=cropped(idx).image;
  I=255-I;
  if transpose
    I=I';
  end
  % Make an RGB version of I
  subplot(m,n,p), imshow(I), drawnow;
  p = p + 1;
  if p > nimages
    break;
  end
end