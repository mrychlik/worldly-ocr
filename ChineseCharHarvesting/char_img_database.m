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
exec(conn, [ 'CREATE TABLE if NOT EXISTS char_bitmaps ' ...
             '(page NUMERIC, ' ...
             'idx NUMERIC, ' ...
             'image VARCHAR); ' ...
             ' '...
             'CREATE INDEX IF NOT EXISTS page_idx ' ...
             'ON char_bitmaps (page, idx); ']);

exec(conn, ['EXPLAIN QUERY PLAN '...
            'SELECT page,idx FROM char_bitmaps WHERE page = "6";'])

try
    for page=pages
        disp(sprintf('Page: %d', page));
        found_first_char = false;
        for idx=1:max_char
            filename = fullfile(char_dir,sprintf(char_img_pattern,page, ...
                                                 idx));
            if exist(filename, 'file') == 2
                if ~found_first_char
                    found_first_char = true;
                end
            else
                break;
            end
            
            if ~found_first_char
                continue;
            end
            I = imread(filename);
            %imshow(I);                
            %title(sprintf('Page %d, char %d', page, idx));
            %drawnow;

            % Write to database
            results = fetch(conn, [ 'select page, idx from char_bitmaps ' ...
                                'WHERE page = ', num2str(page) ' AND '...
                                'idx = ', num2str(idx) '; '] ,1);

            if isempty(results)
                BW = im2bw(I);
                BW = imautocrop(BW);
                BW_data = pack_binary_image(BW);
                disp(sprintf('Insert: page = %d, char %d\n', page, idx));

                insert(conn, 'char_bitmaps',...
                       {'page', 'idx', 'image'},...
                       {page, idx, char(BW_data)} );
            else
                disp(sprintf('Skip: page = %d, char = %d\n', page, idx));
            end
        end
    end
catch me
    close(conn);
    fprintf('Error id %s\n\tMessage:%s\tfile %s, line %d\n', ...
            me.identifier, me.message, me.stack.file, me.stack.line);
end