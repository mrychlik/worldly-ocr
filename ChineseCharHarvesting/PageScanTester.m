classdef PageScanTester

    properties(Constant, Access=private) 
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

            parse(p, varargin{:});

            this.PageDir = p.Results.PageDir;
            this.PageImgPattern = p.Results.PageImgPattern;
            this.Pages = p.Results.Pages;
        end

        function run(this)
            this.test1;
        end

        function test1(this)
            disp(mfilename);
            bg='Original';
            show_dilation = false;
            show_outliers = false;

            for page=this.Pages
                filename=fullfile(this.PageDir,sprintf(this.PageImgPattern,page));
                ps = PageScan(filename);
                ps.show_marked_page_img('Background',bg,...
                            'ShowDilation',show_dilation,...
                            'ShowOutliers',show_outliers);
                title(sprintf('Page %d', page));
                drawnow;
                uiwait(gcf);
            end
        end

    end
    
end