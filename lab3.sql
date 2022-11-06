-- 1
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2018_KAR_GERMANY/T2018_KAR_BUILDINGS.shp t2018_kar_buildings | psql -U postgres -h localhost -p 5432 -d bdp
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2019_KAR_GERMANY/T2019_KAR_BUILDINGS.shp t2019_kar_buildings | psql -U postgres -h localhost -p 5432 -d bdp
with ex1 as (
    select b19.geom, b19.name from t2019_kar_buildings as b19
    left join t2018_kar_buildings as b18
    on b19.geom = b18.geom
    where b18.gid is null
),

--select * from ex1;

-- 2
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2018_KAR_GERMANY/T2018_KAR_POI_TABLE.shp t2018_kar_poi | psql -U postgres -h localhost -p 5432 -d bdp
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2019_KAR_GERMANY/T2019_KAR_POI_TABLE.shp t2019_kar_poi | psql -U postgres -h localhost -p 5432 -d bdp

ex2 as (
    select poi19.gid, poi19.type, poi19.geom from t2019_kar_poi as poi19
    left join t2018_kar_poi as poi18
    on poi19.geom = poi18.geom
    where poi18.gid is null
)

select count(*), ex2.type from ex1
join ex2
on st_distance(ex2.geom,ex1.geom) <= 500
group by ex2.type;

-- 3
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2019_KAR_GERMANY/T2019_KAR_STREETS.shp t2019_kar_streets | psql -U postgres -h localhost -p 5432 -d bdp

create table ex3(
gid int primary key,
link_id float8,
st_name varchar(254) null,
ref_in_id float8,
nref_in_id float8,
func_class varchar(1),
speed_cat varchar(1),
fr_speed_I float8,
to_speed_I float8,
dir_travel varchar(1),
geom geometry );

insert into ex3
select gid,link_id,st_name,ref_in_id,nref_in_id,func_class,speed_cat,fr_speed_l,to_speed_l,dir_travel,ST_Transform(ST_SetSRID(geom,4326), 3068)
from t2019_kar_streets ;

select * from ex3;

-- 4
create table input_points (id int primary key, geom geometry, name char(1));

insert into input_points values  (1, 'POINT(8.36093 49.03174)', 'A'),
                                 (2, 'POINT(8.39876 49.00644)', 'B');

-- 5
update input_points
set geom = ST_Transform(ST_SetSRID(geom,4326), 3068);
select * from input_points;

-- 6
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2019_KAR_GERMANY/T2019_KAR_STREET_NODE.shp t2019_street_node | psql -U postgres -h localhost -p 5432 -d bdp

UPDATE t2019_street_node
SET geom = ST_Transform(ST_SetSRID(geom,4326), 3068);

with ex6 as (
    select st_makeline(geom) as line from input_points
)

select * from t2019_street_node as sn2019
join ex6
on ST_DWITHIN(sn2019.geom,ex6.line, 200);

-- 7
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2019_KAR_GERMANY/T2019_KAR_LAND_USE_A.shp t2019_land_use_A | psql -U postgres -h localhost -p 5432 -d bdp

with stores as (
    select * from t2019_kar_poi where type = 'Sporting Goods Store'
)

select count(distinct stores.gid) from stores
join t2019_land_use_a as parks
on st_dwithin(stores.geom, parks.geom, 300);

-- 8
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2019_KAR_GERMANY/T2019_KAR_RAILWAYS.shp t2019_railways | psql -U postgres -h localhost -p 5432 -d bdp
--shp2pgsql -D -I C:/Users/oliwi/Desktop/bdp/lab3/T2019_KAR_GERMANY/T2019_KAR_WATER_LINES.shp t2019_water_lines | psql -U postgres -h localhost -p 5432 -d bdp

select distinct st_intersection(r.geom, wl.geom) into T2019_KAR_BRIDGES
from t2019_railways as r, t2019_water_lines as wl;

select  * from T2019_KAR_BRIDGES;

