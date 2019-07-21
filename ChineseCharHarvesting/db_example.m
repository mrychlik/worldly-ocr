dbfile=fullfile('example.db');
conn = sqlite(dbfile);
exec(conn, [ 'create table lucky ' ...
             '(name VARCHAR, ' ...
             'lucky_number NUMERIC)' ]);


insert(conn, 'people', ...
       {'name', 'lucky_number'}, ...
       {'John', 37} );

results = fetch(conn, 'select * from lucky');

close(conn);