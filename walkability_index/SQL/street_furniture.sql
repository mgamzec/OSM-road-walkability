----------------------------------
----Table for street furniture----
----------------------------------
/*Get street furniture from OSM*/
DROP TABLE IF EXISTS augsburg.street_furniture;  
CREATE TABLE augsburg.street_furniture AS 
SELECT p.*
FROM planet_osm_point p, planet_osm_point_bbox m 
WHERE ST_Intersects(p.geom, m.geom)
AND p.amenity IN ('bench', 'waste_basket','toilets','fountain','bicycle_parking','bicycle_repair_station','drinking_water'); 
CREATE INDEX ON augsburg.street_furniture USING GIST(geom); 

--Insert street_lamps
INSERT INTO augsburg.street_furniture
SELECT p.*
FROM planet_osm_point p, planet_osm_point_bbox m 
WHERE st_intersects(p.geom,m.geom) 
AND p.highway IN ('street_lamp');



