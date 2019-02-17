function [bottom, top] = vert_size(I)
% Compute the position of the top and bottom of a ligature
S = find(sum(I, 2) > 0);
bottom = min(S);
top = max(S);
end