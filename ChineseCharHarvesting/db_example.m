dbfile = fullfile('example.db');

if exist(dbfile,'file')~=2
    mode = 'create';
else
    mode = 'connect';
end
conn = sqlite(dbfile, mode);
exec(conn, [ 'create table if not exists lucky ' ...
             '(name VARCHAR, ' ...
             'lucky_number NUMERIC)' ]);


insert(conn, 'lucky', ...
       {'name', 'lucky_number'}, ...
       {'John', 37} );

results = fetch(conn, 'select * from lucky');

close(conn);

results