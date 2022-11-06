-- 2
create database bdp;

-- 3
create extension postgis;

-- 4
create table buildings (id int primary key, geom geometry, name char(9));
create table roads (id int primary key, geom geometry, name char(5));
create table poi (id int primary key, geom geometry, name char(1));

-- 5
insert into buildings values  (1, 'polygon((8 4, 8 1.5, 10.5 1.5, 10.5 4, 8 4))', 'BuildingA'),
                              (2, 'polygon((4 7, 4 5, 6 5, 6 7, 4 7))', 'BuildingB'),
                              (3, 'polygon((3 8, 5 8, 5 6, 3 6, 3 8))', 'BuildingC'),
                              (4, 'polygon((9 9, 9 8, 10 8, 10 9, 9 9))', 'BuildingD'),
                              (5, 'polygon((1 2, 2 2, 2 1, 1 1, 1 2))', 'BuildingF');

insert into roads values  (1, 'linestring(0 4.5, 12 4.5)' , 'RoadX'),
                          (2, 'linestring(7.5 10.5, 7.5 0)', 'RoadY');

insert into poi values  (1, 'point(1 3.5)', 'G'),
                        (2, 'point(5.5 1.5)', 'H'),
                        (3, 'point(9.5 6)', 'I'),
                        (4, 'point(6.5 6)', 'J'),
                        (5, 'point(6 9.5)', 'K');

-- 6
-- a
select sum(st_length(geom)) from roads;

-- b
select st_astext(geom), st_area(geom), st_perimeter(geom) from buildings where name = 'BuildingA';

-- c
select name, st_area(geom) from buildings order by name;

-- d
select name, st_perimeter(geom) from buildings order by st_area(geom) desc limit 2;

-- e
select st_distance(buildings.geom, poi.geom) from buildings, poi
where buildings.name = 'BuildingC' and poi.name = 'K';

-- f
with BuildingB as (select geom from buildings where name = 'BuildingB'),
     BuildingC as (select geom from buildings where name = 'BuildingC')
select st_area(BuildingC.geom) - st_area(ST_Intersection(BuildingC.geom, st_buffer(BuildingB.geom, 0.5)))
from BuildingB, BuildingC;

-- g
with RoadX as (select geom from roads where name = 'RoadX')
select name from buildings, RoadX
where st_y(st_centroid(buildings.geom)) > st_y(st_centroid(RoadX.geom));

-- h
with polygon as (select st_geomfromtext('polygon((4 7, 6 7, 6 8, 4 8, 4 7))') as geometry)
select st_area(st_union(geom, geometry)) - st_area(st_intersection(geom, geometry))
from buildings, polygon where name = 'BuildingC';
