function label = B(x)
% First collapse runs of symbols in x, then remove blanks
    y = collapse_runs(x);
    label = y(y~='_');
end

function y = collapse_runs(x)
    if isempty(x) || length(x) == 1 
        y = x;
    elseif x(1) == x(2) 
        y = collapse_runs(x(2:end))
    else 
        [x(1), collapse_runs(x(2:end))]
    end
end
