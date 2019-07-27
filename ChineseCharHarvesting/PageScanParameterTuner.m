classdef PageScanParameterTuner < handle
% PAGESCANPARAMETERTUNER - A utility class for GUI app PageScanParameterTunerApp
    properties
        scan;
    end

    methods
        function this = PageScanParameterTuner
            scan = PageScan;
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
                this.scan.Source = filepath;
            end
        end
    end
end