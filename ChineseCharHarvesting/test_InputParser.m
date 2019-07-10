varargin = {'a',1,'c',false,'b',true};
p = inputParser;
addRequired(p, 'a', @(x)isscalar(x));
addOptional(p, 'b', true, @(x)islogical(x));
addOptional(p, 'c', true, @(x)islogical(x));
parse(p, 'a',varargin{:});
