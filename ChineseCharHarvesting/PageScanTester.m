classdef PageScanTester

    properties(Constant) 
        DefaultPageDir = 'Pages';
        DefaultPageImgPattern = 'page-%02d.ppm';
        DefaultPages = 6:95;
    end
    
    properties
        PageDir;                        % Directory in which pages are
        PageImgPattern;                 % Pattern to use generate page names
        Pages;                          % Range of pages
    end


    methods 

        function this = PageScanTester(varargin)
            p = inputParser;

            addOptional(p, 'PageDir', this.DefaultPageDir, @(x)ischar(x));
            addOptional(p, 'PageImgPattern', this.DefaultPageImgPattern, @(x)ischar(x));
            addOptional(p, 'Pages', this.DefaultPages, @(x)isnumeric(x));

            parse(p, this,varargin{:});

            this.PageDir = p.Results.PageDir;
            this.PageImgPattern = p.Results.PageImgPattern;
            this.Pages = p.Results.Pages;
        end

    end
    
end