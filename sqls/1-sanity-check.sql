create table cat_hadoop.db.t1 (id bigint, data string) using iceberg;
insert into cat_hadoop.db.t1 values (1, 'a'), (2, 'b'), (3, 'c');
select * from cat_hadoop.db.t1;

create table cat_jdbc.db.t2 (id bigint, data string) using iceberg;
insert into cat_jdbc.db.t2 values (4, 'd'), (5, 'e'), (6, 'f');
select * from cat_jdbc.db.t2;