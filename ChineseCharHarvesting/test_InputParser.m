p=make_parser;

varargin1 = {'a',7,'c',false,'b',17,'d',[]};
parse(p, 'a',varargin1{:});
p.Results

p=make_parser;

varargin2 = {'a',7,'b',15,'c',23,'d',[]};
parse(p, 'a',varargin2{:});
p.Results


function p = make_parser
    p = inputParser;
    addRequired(p, 'a', @(x)isscalar(x));
    addParameter(p, 'd', [], @(x)isempty(x));
    addOptional(p, 'b', true, @(x)isscalar(x));
    addOptional(p, 'c', true, @(x)isscalar(x));
end
