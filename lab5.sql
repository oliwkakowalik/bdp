-- 1
create table objects(id int primary key, name varchar(7), geom geometry);

-- a
insert into objects values (1, 'object1', ST_Collect(Array[ST_GeomFromText('LINESTRING(0 0, 1 1)'),
                                                     ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)'),
                                                     ST_GeomFromText('LINESTRING(5 1, 6 1)'),
                                                     ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)')]));

-- b
insert into objects values (2, 'object2', ST_Collect(Array[ST_GeomFromText('LINESTRING(10 6, 14 6)'),
                                                     ST_GeomFromText('CIRCULARSTRING(14 6, 16 4, 14 2)'),
                                                     ST_GeomFromText('CIRCULARSTRING(14 2, 12 0, 10 2)'),
                                                     ST_GeomFromText('LINESTRING(10 2, 10 6)'),
                                                     ST_GeomFromText('CIRCULARSTRING(11 2, 12 3, 13 2)'),
                                                     ST_GeomFromText('CIRCULARSTRING(11 2, 12 1, 13 2)') ]));

-- c
insert into objects values (3, 'object3',  ST_GeomFromText('POLYGON((10 17, 12 13, 7 15, 10 17))'));

-- d
insert into objects values (4, 'object4', ST_Collect(Array[ST_GeomFromText('LINESTRING(20 20, 25 25)'),
                                                     ST_GeomFromText('LINESTRING(25 25, 27 24)'),
                                                     ST_GeomFromText('LINESTRING(27 24, 25 22)'),
                                                     ST_GeomFromText('LINESTRING(25 22, 26 21)'),
                                                     ST_GeomFromText('LINESTRING(26 21, 22 19)'),
                                                     ST_GeomFromText('LINESTRING(22 19, 20.5 19.5)')]));

-- e
insert into objects values (5, 'object5',  ST_Collect(ST_GeomFromText('POINT(30 30 59)'),
                                                      ST_GeomFromText('POINT(38 32 234)')));

-- f
insert into objects values (6, 'object6',  ST_Collect(ST_GeomFromText('POINT(4 2)'),
                                                      ST_GeomFromText('LINESTRING(3 2, 1 1)')));

-- 2
select st_area(st_buffer(st_shortestline(obj3.geom, obj4.geom), 5))
from
(select geom from objects where id = 3) as obj3,
(select geom from objects where id = 4) as obj4;

-- 3
update objects
set geom =  ST_GeomFromText('POLYGON((25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20, 25 25))')
where id = 4;

-- warunek -> pierwszy i ostatni punkt muszą być takie same

-- 4
insert into objects (id, name, geom)
select 7, 'object7', ST_Collect(obj3.geom, obj4.geom)
from
(select geom from objects where id = 3) as obj3,
(select geom from objects where id = 4) as obj4;

-- 5
select  id, st_area(st_buffer(geom, 5))
from objects
where ST_HasArc(geom) = false
order by id;

select ST_Area(ST_Buffer(geom, 5)) from objects o
where ST_HasArc(ST_LineToCurve(geom));
