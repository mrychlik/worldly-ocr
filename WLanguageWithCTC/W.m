function [out, response] = W(str, max_stretch)
% Create a pattern from a string in W-language
%  OUT = W(STR, MAX_STRETCH) accepts a string STR and a number
%  MAX_STRETCH, and returns an N-by-3 matrix of 0-1 representing
%  a valid pattern in the generalized W-language, where
%  each element (row) can repeat up to MAX_STRETCH times.
%    
    nargchk(1,2,nargin);
    if nargin < 2
        max_stretch = 1;
    end
    ob = WLangGenerator(max_stretch);
    out = ob.write_str(str);
    response = ob.decode(out);
end