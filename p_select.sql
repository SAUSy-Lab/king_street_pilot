-- postgis commnads for selecting gps tracks of streetcars and generating points where they cross jarvis and bathurst

-- shp2pgsql import
shp2pgsql -I -s 26917 -W "latin1" ~breaklines.shp breaklines | psql -U ja -d ttc

-- selecting the routes
create table r504514304 as select * from ttc_trips where (route_id = '504' or route_id = '514' or route_id = '304');

ALTER TABLE r504514304 DROP COLUMN clean_geom;
ALTER TABLE r504514304 DROP COLUMN match_geom;


-- counte
select
count(*)
from
r504514304;

-- do they intersect with the two break lines in question
CREATE TABLE int12 AS
SELECT
r504514304.*
FROM r504514304
WHERE
(ST_Intersects(r504514304.orig_geom,
(SELECT breaklines.geom FROM breaklines WHERE id = 1)))
AND
(ST_Intersects(r504514304.orig_geom,
(SELECT breaklines.geom FROM breaklines WHERE id = 2)))
;

-- get table with intersection points on breaklines - and use centroid
SELECT
ST_X(ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 1)))) as int1_X,
ST_Y(ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 1)))) as int1_Y,
ST_X(ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 2)))) as int2_X,
ST_Y(ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 2)))) as int2_Y
FROM
int12
WHERE trip_id = 34371; -- for testing a multipoint intersection




-- then generate the intersection point of breakline and line line

CREATE TABLE o12 AS
SELECT
--ST_AsText(ST_Split(orig_geom,ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 1))))) as split1,
-- ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 1))) as geom1,
ST_AsText(ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 1)))) as int1pt,
ST_AsText(ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 2)))) as int2pt,
-- ST_AsText(ST_Centroid(ST_Intersection(int12.orig_geom, (SELECT breaklines.geom FROM breaklines WHERE id = 2)))) as int2pt,
ST_AsText(orig_geom) as allgeom,
*
FROM
int12;


--WHERE trip_id = 295206;

---
\copy o12 TO 'o12.csv' DELIMITER ',' CSV HEADER;
