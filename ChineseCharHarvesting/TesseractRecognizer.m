classdef TesseractRecognizer
%TESSERACTRECOGNIZER is a wrapper around the Tesseract OCR engine.
    properties
        % The meaning of the parameter '--psm' to Tesseract
        %
        %  0    Orientation and script detection (OSD) only.
        %  1    Automatic page segmentation with OSD.
        %  2    Automatic page segmentation, but no OSD, or OCR. (not implemented)
        %  3    Fully automatic page segmentation, but no OSD. (Default)
        %  4    Assume a single column of text of variable sizes.
        %  5    Assume a single uniform block of vertically aligned text.
        %  6    Assume a single uniform block of text.
        %  7    Treat the image as a single text line.
        %  8    Treat the image as a single word.
        %  9    Treat the image as a single word in a circle.
        % 10    Treat the image as a single character.
        % 11    Sparse text. Find as much text as possible in no particular order.
        % 12    Sparse text with OSD.
        % 13    Raw line. Treat the image as a single text line,
        %       bypassing hacks that are Tesseract-specific.
        psm;
        language;
    end

    properties(Access = private)
        tesseract_path = 'tesseract';   % The path of Tesseract executable
    end

    methods
        function this = TesseractRecognizer(psm, language)
            p = inputParser;
            % NOTE: Default psm is line
            addOptional(p, 'PageSegmentationMode', 7,...
                        @(x)(isscalar(x)&&(x<=13)&&(x>=0)));
            addOptional(p, 'Language', 'chi_tra',...
                        @(x)(isscalar(x)&&(x<=13)&&(x>=0)));
            parse(p, varargin{:});

            this.psm = p.Results.PageSegmentationMode;
            this.language = p.Results.Language;
            TesseractRecognizer.locate_tesseract_exec;
        end
    end

    methods(Static)
        function [BWCropped,BBox]=bbox(BW)
        %BBOX Extract the bounding box of a BW image and crop the image.
        %  [BWCROPPED,BBOX] = BBOX(BW) accepts a black-and-white image
        %  BW and it returns a cropped image BWCROPPED and the bounding
        %  box BBBOX.

        % Create a mask
        % Idiom: convert a pixel list to mask
            [I,J]=find(BW);
            % Crop image to bounding box of object
            BBox=[min(J),min(I),range(J),range(I)];
            BWCropped=imcrop(BW,BBox);
        end

        function locate_tesseract_exec
        % LOCATE_TESSERACT_EXEC sets the path of the Tesseract program             
        % TODO: Implement this carefully.
            if ismac
                % Code to run on Mac platform
                % Code to run on Linux platform
                [status,result] = system('which tesseract');
                if status == 0
                    fprintf('Found tesseract executable: %s\n', result);
                    this.tesseract_path = result;
                else
                    fprintf('Tesseract is not in the $PATH.');
                end
            elseif isunix
                % Code to run on Linux platform
                [status,result] = system('which tesseract');
                if status == 0
                    fprintf('Found tesseract executable: %s\n', result);
                    this.tesseract_path = result;
                else
                    fprintf('Tesseract is not in the $PATH.');
                end
            elseif ispc
                % Code to run on Windows platform
                % Code to run on Linux platform
                [status,result] = system('where tesseract');
                if status == 0
                    fprintf('Found tesseract: %s', result);
                    this.tesseract_path = result;
                else
                    fprintf('Tesseract is not in the $PATH.');
                end
            else
                disp('Platform not supported')
            end
        end
    end

    methods
        function [str, status] = recognize(this, BW)
        %RECOGNIZE Perform OCR on a BW image.
        % [STR, STATUS] = RECOGNIZE(THIS, BW) takes a binary image BW and
        % performs OCR on it. Upon success, as string STR is returned
        % and STATUS is set to 0.
        % Upon failure, STATUS is non-zero.
            fname = tempname;
            imwrite(BW, fname, 'PNG');
            base = fname;
            cmd = sprintf('%s --psm %d -l %s %s %s', ...
                          this.tesseract_path,...
                          this.psm, ...
                          this.language,...
                          fname, ...
                          base);
            [status,result] = system(cmd);
            delete(fname);
            if status == 0
                txtfname=fullfile([base,'.txt']);
                fh = fopen(txtfname,'r');
                bytes = fread(fh, 'uint8')';
                fclose(fh);
                delete(txtfname);
                try
                    str = native2unicode(bytes,'UTF-8');
                    disp(str);
                catch ME
                    rethrow(ME);
                end
            else
                error('A call to tesseract failed. Is it installed?');
            end
        end
    end
end