% Write images to a database as monochrome bitmaps

% Directory full of character(part) images
char_dir=fullfile('PChars');
db_file=fullfile('chars.db');
char_img_pattern='page%02d-char%05d.png';
pages = 6:95;
max_char = 999;                       % Number bigger than chars per page

if exist(db_file, 'file') ~= 2
    mode = 'create';
else
    mode = 'connect';
end
conn = sqlite(db_file, mode);
exec(conn, [ 'create table if not exists char_bitmaps ' ...
             '(page NUMERIC,' ...
             'idx NUMERIC, ' ...
             'image VARCHAR)' ]);


for page=pages
    disp(sprintf('Page: %d', page));
    found_first_char = false;
    for idx=1:max_char
        filename = fullfile(char_dir,sprintf(char_img_pattern,page, ...
                                             idx));
        if exist(filename, 'file') == 2
            if ~found_first_char
                disp(sprintf('Found first char %d on page %d', idx, page));                
                found_first_char = true;
            end
        else
            if found_first_char
                disp(sprintf('Reached last char %d on page %d', idx, ...
                             page));
            end
            break;
        end
        if found_first_char
            disp(sprintf('\tChar: %d\n', idx));        
        end
    
        if ~found_first_char
            continue;
        end
        I = imread(filename);
        imshow(I);
        title(sprintf('Page %d, char %d', page, idx));
        drawnow; pause(0.2);

        % Write to database
        BW = img2bw(I);
        BW = imautocrop(BW);
        BW_data = pack_binary_image(BW);
        insert(this.conn, 'bitmaps',...
               {'page', 'idx', 'image'},...
               {page, idx, BW_data} );
    end
end