classdef GoogleTranslator
%GOOGLETRANSLATOR Calls Google Cloud to translate Pashto to English.
    methods
        function this = GoogleTranslator()
        %GoogleTranslator Constructor
        end


        function [result, status] = translate_string(~, str)
        %Translate a string in Pashto to English
        %  [RESULT, STATUS] = TRANSLATE_STRING(THIS, STR) accepts a name of
        %  a UTF-8 encoded string in Pashto named STR, and it returns
        %  the translated file as a string RESULT. Upon failure non-zero
        %  STATUS is returned.

            cmd = sprintf("pashto2english '%s'",str);
            [status,result] = system(cmd);
        end

        function [result, status] = translate_file(this, fname)
        %Translate a file in Pashto to English
        %  [RESULT, STATUS] = TRANSLATE_FILE(FNAME) accepts a name of
        %  a UTF-8 encoded file in Pashto named FNAME, and it returns
        %  the translated file as a string RESULT. Upon failure non-zero
        %  STATUS is returned.
            [fh,msg] = fopen(fname);
            if ~isempty(msg)
                disp(msg);
                result='';
                status = 1;
                return;
            end
            bytes = fread(fh,'uint8')';
            fclose(fh);
            str = native2unicode(bytes,'UTF-8');
            [result,status] = translate_string(this, str);
        end
    end
end