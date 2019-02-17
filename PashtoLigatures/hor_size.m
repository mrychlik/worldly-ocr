function [left, right] = hor_size(I)
% Compute the position of the top and bottom of a ligature
S = find(sum(I, 1) > 0);
left = min(S);
right = max(S);
end