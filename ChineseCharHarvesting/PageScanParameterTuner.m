classdef PageScanParameterTuner < handle
% PAGESCANPARAMETERTUNER - A utility class for GUI app PageScanParameterTunerApp
    properties
        app;
        scan;
    end

    methods
        function this = PageScanParameterTuner(app)
            if nargin > 0
                this.app = app
            end
            this.scan = PageScan;
        end


        function this = LoadFcn(this, event)
        % LOADFCN loads saved state from file
            [file, path] = uigetfile('*.bmp *.png *.tif *.ppm',...
                                     'Select an image file', 'page-06.ppm');

            if isequal(file,0)
                disp(['User selected ', fullfile(path,file)]);
                disp('User selected Cancel');
            else
                filepath = fullfile(path,file)
                this.LoadFile(filepath);

            end
        end

        function this = LoadFile(this, filepath)
            this.scan.Source = filepath;
            this.show_marked_page_img;
        end


        function show_marked_page_img(this)
            opts.Background = 'Original';
            opts.ShowDilation = true;
            opts.ShowOutliers = false;
            opts.Axes = this.app.UIAxes;

            this.scan.show_marked_page_img(opts);
        end

    end
end