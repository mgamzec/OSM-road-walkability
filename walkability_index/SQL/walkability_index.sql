
----##########################################################################################################################----
----###########################################################ADD COLUMNS TO edge########################################################----
----##########################################################################################################################----


ALTER TABLE edge 
    ADD COLUMN IF NOT EXISTS maxspeed numeric,
    ADD COLUMN IF NOT EXISTS covered text, 
    ADD COLUMN IF NOT EXISTS cnt_crossings integer,
    ADD COLUMN IF NOT EXISTS cnt_accidents integer,
    ADD COLUMN IF NOT EXISTS cnt_benches integer,
    ADD COLUMN IF NOT EXISTS cnt_waste_baskets integer,
    ADD COLUMN IF NOT EXISTS cnt_fountains integer,
    ADD COLUMN IF NOT EXISTS cnt_toilets integer,
	ADD COLUMN IF NOT EXISTS cnt_trees integer,
	ADD COLUMN IF NOT EXISTS nature integer,
    ADD COLUMN IF NOT EXISTS population text,
    ADD COLUMN IF NOT EXISTS planet_osm_point_bboxtext text,
    ADD COLUMN IF NOT EXISTS landuse text[],
    ADD COLUMN IF NOT EXISTS street_furniture integer,
    ADD COLUMN IF NOT EXISTS sidewalk_quality_standard integer,
    ADD COLUMN IF NOT EXISTS sidewalk_quality_senior integer,
    ADD COLUMN IF NOT EXISTS sidewalk_quality_child integer,
    ADD COLUMN IF NOT EXISTS sidewalk_quality_wheelchair integer,
    ADD COLUMN IF NOT EXISTS sidewalk_quality_woman integer,
    ADD COLUMN IF NOT EXISTS traffic_protection_standard integer, 
    ADD COLUMN IF NOT EXISTS traffic_protection_senior integer, 
    ADD COLUMN IF NOT EXISTS traffic_protection_child integer, 
    ADD COLUMN IF NOT EXISTS traffic_protection_wheelchair integer, 
    ADD COLUMN IF NOT EXISTS traffic_protection_woman integer, 
    ADD COLUMN IF NOT EXISTS security_standard integer,
    ADD COLUMN IF NOT EXISTS security_senior integer, 
    ADD COLUMN IF NOT EXISTS security_child integer, 
    ADD COLUMN IF NOT EXISTS security_wheelchair integer, 
    ADD COLUMN IF NOT EXISTS security_woman integer, 
    ADD COLUMN IF NOT EXISTS liveliness_standard integer,
    ADD COLUMN IF NOT EXISTS liveliness_senior integer,
    ADD COLUMN IF NOT EXISTS liveliness_child integer,
    ADD COLUMN IF NOT EXISTS liveliness_wheelchair integer,
    ADD COLUMN IF NOT EXISTS liveliness_woman integer,
    ADD COLUMN IF NOT EXISTS urban_equipment_standard integer,
    ADD COLUMN IF NOT EXISTS urban_equipment_senior integer,
    ADD COLUMN IF NOT EXISTS urban_equipment_child integer,
    ADD COLUMN IF NOT EXISTS urban_equipment_wheelchair integer,
    ADD COLUMN IF NOT EXISTS urban_equipment_woman integer,
    ADD COLUMN IF NOT EXISTS walkability_standard integer, 
    ADD COLUMN IF NOT EXISTS walkability_senior integer, 
    ADD COLUMN IF NOT EXISTS walkability_child integer, 
    ADD COLUMN IF NOT EXISTS walkability_wheelchair integer, 
    ADD COLUMN IF NOT EXISTS walkability_woman integer, 
    ADD COLUMN IF NOT EXISTS data_quality float,
    ADD COLUMN IF NOT EXISTS sidewalk_width_num numeric,
    ADD COLUMN IF NOT EXISTS impedance_walkability_standard float,
    ADD COLUMN IF NOT EXISTS impedance_walkability_senior float,
    ADD COLUMN IF NOT EXISTS impedance_walkability_child float,
    ADD COLUMN IF NOT EXISTS impedance_walkability_wheelchair float,
    ADD COLUMN IF NOT EXISTS impedance_walkability_woman float;



----##########################################################################################################################----
----########################################################SIDEWALK QUALITY##################################################----
----##########################################################################################################################----
--prepara data
UPDATE edge f 
SET sidewalk = 'yes' 
WHERE sidewalk IS NULL 
AND highway in ('footway', 'path', 'cycleway', 'living_street', 'steps', 'pedestrian', 'track');

UPDATE edge f 
SET surface = 'asphalt' 
WHERE surface IS NULL 
AND highway IN ('residential','tertiary','secondary','secondary_link','primary','primary_link','living_street');

UPDATE edge f 
SET surface = NULL 
WHERE surface NOT IN ('paved','asphalt','concrete','concrete:lanes','paving_stones','cobblestone:flattened','stone','sandstone','sett','metal','unhewn_cobblestone','cobblestone','unpaved','compacted','fine_gravel','metal_grid','gravel','pebblestone','rock','wood','ground','dirt','earth','grass','grass_paver','mud','sand');

-- UPDATE edge f
-- SET incline_percent = slope 
-- FROM slope_profile_edge s 
-- WHERE ST_EQUALS(f.geom, s.geom);

UPDATE edge 
SET surface = 'unpaved' 
WHERE highway = 'track' 
AND surface IS NULL; 

-- smoothness
UPDATE edge 
SET smoothness = 'very_good' 
WHERE surface = 'asphalt' 
AND smoothness IS NULL; 

UPDATE edge 
SET smoothness = 'good' 
WHERE surface IN ('compacted','paving_stones') 
AND smoothness IS NULL; 

UPDATE edge 
SET smoothness = 'intermediate' 
WHERE surface = 'fine_gravel' 
AND smoothness IS NULL; 

UPDATE edge 
SET smoothness = 'bad' 
WHERE surface IN ('gravel','unpaved','ground','dirt') 
AND smoothness IS NULL; 

UPDATE edge 
SET smoothness = 'very_bad' 
WHERE surface IN ('grass') 
AND smoothness IS NULL; 

-- sidewalk width
UPDATE edge 
SET sidewalk_width_num = width 
WHERE width IS NOT NULL; 

UPDATE edge 
SET sidewalk_width_num = sidewalk_both_width 
WHERE sidewalk_both_width IS NOT NULL 
AND width IS NULL; 

UPDATE edge 
SET sidewalk_width_num = (sidewalk_left_width+sidewalk_right_width)::float/2 
WHERE sidewalk_left_width IS NOT NULL AND sidewalk_right_width IS NOT NULL
AND width IS NULL; 

UPDATE edge 
SET sidewalk_width_num = sidewalk_left_width 
WHERE sidewalk_left_width IS NOT NULL 
AND width IS NULL; 

UPDATE edge 
SET sidewalk_width_num = sidewalk_right_width 
WHERE sidewalk_right_width IS NOT NULL 
AND width IS NULL; 

--incline
UPDATE edge 
SET incline_percent = 5
WHERE incline IN ('up','down','Up','Down'); 

-- Slope is computed using a digital elevation model in a python function
-- UPDATE edge 
-- SET incline_percent = 0 
-- WHERE incline_percent IS NULL
-- OR length_m < 0.5; 

--calculate score -- STANDARD
UPDATE edge f SET sidewalk_quality_standard = 
round(group_index(
	ARRAY[
		select_weight_walkability('sidewalk',
			(CASE WHEN lower(sidewalk) IN ('no','none') THEN 'no' 
			WHEN lower(sidewalk) = 'yes' THEN 'yes'
			ELSE NULL END),'standard'
		), 
		select_weight_walkability_range('sidewalk_width_num',sidewalk_width_num,'standard'),
		select_weight_walkability('surface',surface,'standard'),
		select_weight_walkability('smoothness',smoothness,'standard'),
		select_weight_walkability_range('incline_percent', incline_percent::numeric,'standard'),
		select_weight_walkability('highway',highway,'standard'),
		select_weight_walkability('wheelchair_classified',wheelchair_classified,'standard')
	],
	ARRAY[
		select_full_weight_walkability('sidewalk','standard'),
		select_full_weight_walkability('sidewalk_width_num','standard'),
		select_full_weight_walkability('surface','standard'),
		select_full_weight_walkability('smoothness','standard'),
		select_full_weight_walkability('incline_percent','standard'),
		select_full_weight_walkability('highway','standard'),
		select_full_weight_walkability('wheelchair_classified','standard')
	]
),0);

--calculate score -- SENIOR
UPDATE edge f SET sidewalk_quality_senior = 
round(group_index(
	ARRAY[
		select_weight_walkability('sidewalk',
			(CASE WHEN lower(sidewalk) IN ('no','none') THEN 'no' 
			WHEN lower(sidewalk) = 'yes' THEN 'yes'
			ELSE NULL END),'senior'
		), 
		select_weight_walkability('surface',surface,'senior'),
		select_weight_walkability_range('sidewalk_width_num',sidewalk_width_num,'senior'),
		select_weight_walkability('smoothness',smoothness,'senior'),
		select_weight_walkability_range('incline_percent', incline_percent::numeric,'senior'),
		select_weight_walkability('highway',highway,'senior'),
		select_weight_walkability('wheelchair_classified',wheelchair_classified,'senior')
	],
	ARRAY[
		select_full_weight_walkability('sidewalk','senior'),
		select_full_weight_walkability('sidewalk_width_num','senior'),
		select_full_weight_walkability('surface','senior'),
		select_full_weight_walkability('smoothness','senior'),
		select_full_weight_walkability('incline_percent','senior'),
		select_full_weight_walkability('highway','senior'),
		select_full_weight_walkability('wheelchair_classified','senior')
	]
),0);

UPDATE edge
SET sidewalk_quality_senior = 100
WHERE traffic_protection_standard > 100;

--calculate score -- CHILD
UPDATE edge f SET sidewalk_quality_child = 
round(group_index(
	ARRAY[
		select_weight_walkability('sidewalk',
			(CASE WHEN lower(sidewalk) IN ('no','none') THEN 'no' 
			WHEN lower(sidewalk) = 'yes' THEN 'yes'
			ELSE NULL END),'child'
		), 
		select_weight_walkability_range('sidewalk_width_num',sidewalk_width_num,'child'),
		select_weight_walkability('surface',surface,'child'),
		select_weight_walkability('smoothness',smoothness,'child'),
		select_weight_walkability_range('incline_percent', incline_percent::numeric,'child'),
		select_weight_walkability('highway',highway,'child'),
		select_weight_walkability('wheelchair_classified',wheelchair_classified,'child')
	],
	ARRAY[
		select_full_weight_walkability('sidewalk','child'),
		select_full_weight_walkability('sidewalk_width_num','child'),
		select_full_weight_walkability('surface','child'),
		select_full_weight_walkability('smoothness','child'),
		select_full_weight_walkability('incline_percent','child'),
		select_full_weight_walkability('highway','child'),
		select_full_weight_walkability('wheelchair_classified','child')
	]
),0);

--calculate score -- WHEELCHAIR
UPDATE edge f SET sidewalk_quality_wheelchair = 
round(group_index(
	ARRAY[
		select_weight_walkability('sidewalk',
			(CASE WHEN lower(sidewalk) IN ('no','none') THEN 'no' 
			WHEN lower(sidewalk) = 'yes' THEN 'yes'
			ELSE NULL END),'wheelchair'
		), 
		select_weight_walkability_range('sidewalk_width_num',sidewalk_width_num,'wheelchair'),
		select_weight_walkability('surface',surface,'wheelchair'),
		select_weight_walkability('smoothness',smoothness,'wheelchair'),
		select_weight_walkability_range('incline_percent', incline_percent::numeric,'wheelchair'),
		select_weight_walkability('highway',highway,'wheelchair'),
		select_weight_walkability('wheelchair_classified',wheelchair_classified,'wheelchair')
	],
	ARRAY[
		select_full_weight_walkability('sidewalk','wheelchair'),
		select_full_weight_walkability('sidewalk_width_num','wheelchair'),
		select_full_weight_walkability('surface','wheelchair'),
		select_full_weight_walkability('smoothness','wheelchair'),
		select_full_weight_walkability('incline_percent','wheelchair'),
		select_full_weight_walkability('highway','wheelchair'),
		select_full_weight_walkability('wheelchair_classified','wheelchair')
	]
),0);

--calculate score -- WOMAN
UPDATE edge f SET sidewalk_quality_woman = 
round(group_index(
	ARRAY[
		select_weight_walkability('sidewalk',
			(CASE WHEN lower(sidewalk) IN ('no','none') THEN 'no' 
			WHEN lower(sidewalk) = 'yes' THEN 'yes'
			ELSE NULL END),'woman'
		), 
		select_weight_walkability_range('sidewalk_width_num',sidewalk_width_num,'woman'),
		select_weight_walkability('surface',surface,'woman'),
		select_weight_walkability('smoothness',smoothness,'woman'),
		select_weight_walkability_range('incline_percent', incline_percent::numeric,'woman'),
		select_weight_walkability('highway',highway,'woman'),
		select_weight_walkability('wheelchair_classified',wheelchair_classified,'woman')
	],
	ARRAY[
		select_full_weight_walkability('sidewalk','woman'),
		select_full_weight_walkability('sidewalk_width_num','woman'),
		select_full_weight_walkability('surface','woman'),
		select_full_weight_walkability('smoothness','woman'),
		select_full_weight_walkability('incline_percent','woman'),
		select_full_weight_walkability('highway','woman'),
		select_full_weight_walkability('wheelchair_classified','woman')
	]
),0);

----##########################################################################################################################----
----#######################################################TRAFFIC PROTECTION#################################################----
----##########################################################################################################################----
--lanes
UPDATE edge 
SET lanes = 0 
WHERE highway IN ('footway','pedestrian','steps','cycleway');

UPDATE edge 
SET lanes = 1 
WHERE highway IN ('track','path','service','unclassified','living_street');

UPDATE edge 
SET lanes = 2
WHERE highway IN ('residential','secondary','secondary_link','tertiary_link','tertiary','road') AND lanes = 0;

UPDATE edge 
SET lanes = 4
WHERE highway IN ('motorway','primary','primary_link','motorway_link','trunk_link') AND lanes = 0;

DROP TABLE IF EXISTS lanes_buffer;
CREATE TABLE lanes_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(w.geom,0.00015), 50) AS geom, lanes
FROM edge w, planet_osm_polygon_bbox s 
WHERE w.highway IN ('living_street','residential','secondary','secondary_link','tertiary','tertiary_link','primary','primary_link','trunk','motorway','service')
AND ST_Intersects(w.geom,s.geom)
AND lanes IS NOT NULL; 

CREATE INDEX ON lanes_buffer USING GIST(geom);

DROP TABLE IF EXISTS footpath_lanes;
CREATE TEMP TABLE footpath_lanes AS 
SELECT id, SUM(COALESCE(arr_polygon_attr[array_position(arr_shares, array_greatest(arr_shares))]::integer, 0)) AS lanes
FROM edge_get_polygon_attr('lanes_buffer','lanes')
GROUP BY id ;
ALTER TABLE footpath_lanes ADD PRIMARY KEY(id); 

ALTER TABLE edge
ADD lanes_impact float8; 

UPDATE edge f
SET lanes_impact = l.lanes 
FROM footpath_lanes l
WHERE f.id = l.id; 

--maxspeed
UPDATE edge 
SET maxspeed_backward = 25
WHERE highway = 'service';

DROP TABLE IF EXISTS maxspeed_buffer;
CREATE TEMP TABLE maxspeed_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(w.geom,0.00015), 50) AS geom, maxspeed_backward AS maxspeed
FROM edge w, planet_osm_polygon_bbox s 
WHERE highway IN ('living_street','residential','secondary','secondary_link','tertiary','tertiary_link','primary','primary_link','trunk','motorway','service')
AND ST_Intersects(w.geom,s.geom)
AND maxspeed_backward IS NOT NULL; 

CREATE INDEX ON maxspeed_buffer USING GIST(geom);

DROP TABLE IF EXISTS footpath_maxspeed;
CREATE TABLE footpath_maxspeed AS 
SELECT id, MAX(COALESCE(arr_polygon_attr[array_position(arr_shares, array_greatest(arr_shares))]::integer, 0)) AS maxspeed
FROM edge_get_polygon_attr('maxspeed_buffer','maxspeed')
GROUP BY id; 			
ALTER TABLE footpath_maxspeed ADD PRIMARY KEY(id);

UPDATE edge f
SET maxspeed = m.maxspeed 
FROM footpath_maxspeed m
WHERE f.id = m.id;

--parking
DO $$
	DECLARE 
    	buffer float := meter_degree() * 15;
    BEGIN 
	    WITH footpaths_parking AS 
	    (
			SELECT f.id 
			FROM edge f, landuse_osm l 
			WHERE ST_Intersects(l.geom, f.geom)
			AND l.landuse = 'parking'
		)
		UPDATE edge f 
		SET parking = 'off_street'
		FROM footpaths_parking p 
		WHERE f.id = p.id; 
	END; 
$$;


/*
DO $$
	DECLARE 
    	buffer float := meter_degree() * 10;
    BEGIN 
	    DROP TABLE IF EXISTS buffer_parking; 
	    CREATE TABLE buffer_parking AS 
	    SELECT ST_BUFFER(geom, buffer) AS geom, 'on_street' AS parking 
		FROM parking 
		WHERE parking_lane NOT IN ('no','no_parking','no_stopping')
		OR parking_lane IS NULL; 
		
	
	END; 
$$;

SELECT count(parking_lane), parking_lane 
FROM parking 
GROUP BY parking_lane 


WITH footpaths_no_parking AS 
(
	SELECT DISTINCT id 
	FROM edge_cleaned w, 
	LATERAL (
		SELECT DISTINCT parking 
		FROM 
		(
			SELECT w.parking 
			UNION ALL 
			SELECT w.parking_lane_left
			UNION ALL 
			SELECT w.parking_lane_right
			UNION ALL 
			SELECT w.parking_lane_both
		) x
		WHERE parking IN ('no_stopping','no_parking','no')
	) p
)
UPDATE edge f  
SET parking = 'no'
FROM footpaths_no_parking n 
WHERE f.id = n.id;
*/

--

UPDATE edge 
SET parking = 'on_street' 
WHERE parking_lane_both IN ('parallel','marked','perpendicular','diagonal')
OR parking_lane_left IN ('parallel','marked','perpendicular','diagonal')
OR parking_lane_right IN ('parallel','marked','perpendicular','diagonal');

UPDATE edge 
SET parking = 'on_street'
WHERE highway = 'residential' AND parking IS NULL;

UPDATE edge 
SET parking = 'no' 
WHERE parking IS NULL;

--street crossings
-- Create temp table to count street crossings
DROP TABLE IF EXISTS relevant_crossings;
CREATE TEMP TABLE relevant_crossings AS 
SELECT geom 
FROM street_crossings 
WHERE crossing IN ('zebra','traffic_signals'); 

CREATE INDEX ON relevant_crossings USING GIST(geom);

/*Assing number of crossing to edge*/
ALTER TABLE edge DROP COLUMN IF EXISTS cnt_crossings;
ALTER TABLE edge ADD COLUMN cnt_crossings int; 
WITH cnt_table AS 
(
	SELECT id, COALESCE(points_sum) AS points_sum 
	FROM edge_get_points_sum('relevant_crossings', 30)
)
UPDATE edge f
SET cnt_crossings = points_sum 
FROM cnt_table c
WHERE f.id = c.id;

/*Label footpaths that are not affected by crossings*/
UPDATE edge 
SET cnt_crossings = -1
WHERE maxspeed <= 30 
OR maxspeed IS NULL OR highway IN ('residential','service');
 

/*For each footpath noise levels (day and night) are derived an aggregated for different sound sources*/
-- DO $$     
-- 	DECLARE 
-- 		noise_key TEXT;
--     BEGIN     

-- 		IF EXISTS ( 	
-- 			SELECT 1
--             FROM   information_schema.tables 
--             WHERE  table_schema = 'public'
--             AND    table_name = 'noise'
--         ) 
-- 		THEN 
		
-- 			DROP TABLE IF EXISTS noise_levels_footpaths;
-- 			CREATE TEMP TABLE noise_levels_footpaths 
-- 			(
-- 				gid serial, 
-- 				footpath_id integer, 
-- 				noise_level_db integer, 
-- 				noise_type text,
-- 			CONSTRAINT noise_levels_footpaths_pkey PRIMARY KEY (gid)
-- 			);

-- 			FOR noise_key IN SELECT DISTINCT noise_type FROM noise  	
-- 			LOOP
-- 				RAISE NOTICE 'Following noise type will be calculated: %', noise_key;
-- 				DROP TABLE IF EXISTS noise_subdivide;
-- 				CREATE TEMP TABLE noise_subdivide AS 
-- 				SELECT ST_SUBDIVIDE((ST_DUMP(geom)).geom, 50) AS geom, noise_level_db  
-- 				FROM noise fn 
-- 				WHERE noise_type = noise_key;
				
-- 				ALTER TABLE noise_subdivide ADD COLUMN gid serial;
-- 				ALTER TABLE noise_subdivide ADD PRIMARY KEY(gid);
-- 				CREATE INDEX ON noise_subdivide USING GIST(geom);
				
-- 				INSERT INTO noise_levels_footpaths(footpath_id,noise_level_db,noise_type)
-- 				SELECT id, 
-- 				COALESCE(arr_polygon_attr[array_position(arr_shares, array_greatest(arr_shares))]::integer, 0) AS val, noise_key
-- 				FROM edge_get_polygon_attr('noise_subdivide','noise_level_db');
				
-- 			END LOOP;
-- 		END IF; 
--     END
-- $$ ;

-- WITH noise_day AS 
-- (
-- 	SELECT footpath_id, ROUND((10 * LOG(SUM(power(10,(noise_level_db::numeric/10))))),2) AS noise 
-- 	FROM noise_levels_footpaths
-- 	WHERE noise_type LIKE '%day%'
-- 	GROUP BY footpath_id
-- )
-- UPDATE edge f
-- SET noise_day = n.noise 
-- FROM noise_day n  
-- WHERE f.id = n.footpath_id; 

-- WITH noise_night AS 
-- (
-- 	SELECT footpath_id, ROUND((10 * LOG(SUM(power(10,(noise_level_db::numeric/10))))),2) AS noise 
-- 	FROM noise_levels_footpaths
-- 	WHERE noise_type LIKE '%night%'
-- 	GROUP BY footpath_id
-- )
-- UPDATE edge f
-- SET noise_night = n.noise 
-- FROM noise_night n  
-- WHERE f.id = n.footpath_id; 

/*Count Accidents*/
/*Assing number of crossing to edge*/
DROP TABLE IF EXISTS accidents_foot; 
CREATE TABLE accidents_foot AS 
SELECT geom 
FROM accidents 
WHERE istfuss = '1'; 

CREATE INDEX ON accidents_foot USING GIST(geom);

WITH cnt_table AS 
(
SELECT f.id, COALESCE(points_sum,0) AS points_sum 
FROM edge f 
LEFT JOIN edge_get_points_sum('accidents_foot', 30) c
ON f.id = c.id 	
)
UPDATE edge f
SET cnt_accidents = points_sum 
FROM cnt_table c
WHERE f.id = c.id;

--Aggregated score -- STANDARD
UPDATE edge f SET traffic_protection_standard = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('lanes',lanes_impact,'standard'),
		select_weight_walkability_range('maxspeed',maxspeed,'standard'),
		select_weight_walkability_range('crossings',cnt_crossings,'standard'),
		select_weight_walkability_range('accidents',cnt_accidents,'standard'),
		--select_weight_walkability_range('noise',noise_day::numeric,'standard'),
		select_weight_walkability('parking',parking,'standard')
	],
	ARRAY[
		select_full_weight_walkability('lanes','standard'),
		select_full_weight_walkability('maxspeed','standard'),
		select_full_weight_walkability('crossings','standard'),
		select_full_weight_walkability('accidents','standard'),
		--select_full_weight_walkability('noise','standard'),
		select_full_weight_walkability('parking','standard')
	]
),0);

UPDATE edge SET traffic_protection_standard = 100
WHERE traffic_protection_standard IS NULL; 

UPDATE edge
SET traffic_protection_standard = (traffic_protection_standard - 50) / 0.5;

UPDATE edge
SET traffic_protection_standard = 0
WHERE traffic_protection_standard < 0;

--Aggregated score -- SENIOR
UPDATE edge f SET traffic_protection_senior = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('lanes',lanes_impact,'senior'),
		select_weight_walkability_range('maxspeed',maxspeed,'senior'),
		select_weight_walkability_range('crossings',cnt_crossings,'senior'),
		select_weight_walkability_range('accidents',cnt_accidents,'senior'),
		--select_weight_walkability_range('noise',noise_day::numeric,'senior'),
		select_weight_walkability('parking',parking,'senior')
	],
	ARRAY[
		select_full_weight_walkability('lanes','senior'),
		select_full_weight_walkability('maxspeed','senior'),
		select_full_weight_walkability('crossings','senior'),
		select_full_weight_walkability('accidents','senior'),
		--select_full_weight_walkability('noise','senior'),
		select_full_weight_walkability('parking','senior')
	]
),0);

UPDATE edge SET traffic_protection_senior = 100
WHERE traffic_protection_senior IS NULL; 

UPDATE edge
SET traffic_protection_senior = (traffic_protection_senior - 50) / 0.5;

UPDATE edge
SET traffic_protection_senior = 0
WHERE traffic_protection_senior < 0;

--Aggregated score -- CHILD
UPDATE edge f SET traffic_protection_child = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('lanes',lanes_impact,'child'),
		select_weight_walkability_range('maxspeed',maxspeed,'child'),
		select_weight_walkability_range('crossings',cnt_crossings,'child'),
		select_weight_walkability_range('accidents',cnt_accidents,'child'),
		--select_weight_walkability_range('noise',noise_day::numeric,'child'),
		select_weight_walkability('parking',parking,'child')
	],
	ARRAY[
		select_full_weight_walkability('lanes','child'),
		select_full_weight_walkability('maxspeed','child'),
		select_full_weight_walkability('crossings','child'),
		select_full_weight_walkability('accidents','child'),
		--select_full_weight_walkability('noise','child'),
		select_full_weight_walkability('parking','child')
	]
),0);

UPDATE edge SET traffic_protection_child = 100
WHERE traffic_protection_child IS NULL; 

UPDATE edge
SET traffic_protection_child = (traffic_protection_child - 50) / 0.5;

UPDATE edge
SET traffic_protection_child = 0
WHERE traffic_protection_child < 0;

--Aggregated score -- WOMAN
UPDATE edge f SET traffic_protection_woman = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('lanes',lanes_impact,'woman'),
		select_weight_walkability_range('maxspeed',maxspeed,'woman'),
		select_weight_walkability_range('crossings',cnt_crossings,'woman'),
		select_weight_walkability_range('accidents',cnt_accidents,'woman'),
		--select_weight_walkability_range('noise',noise_day::numeric,'woman'),
		select_weight_walkability('parking',parking,'woman')
	],
	ARRAY[
		select_full_weight_walkability('lanes','woman'),
		select_full_weight_walkability('maxspeed','woman'),
		select_full_weight_walkability('crossings','woman'),
		select_full_weight_walkability('accidents','woman'),
		--select_full_weight_walkability('noise','woman'),
		select_full_weight_walkability('parking','woman')
	]
),0);

UPDATE edge SET traffic_protection_woman = 100
WHERE traffic_protection_woman IS NULL; 

UPDATE edge
SET traffic_protection_woman = (traffic_protection_woman - 50) / 0.5;

UPDATE edge
SET traffic_protection_woman = 0
WHERE traffic_protection_woman < 0;

--Aggregated score -- WHEELCHAIR
UPDATE edge f SET traffic_protection_wheelchair = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('lanes',lanes_impact,'wheelchair'),
		select_weight_walkability_range('maxspeed',maxspeed,'wheelchair'),
		select_weight_walkability_range('crossings',cnt_crossings,'wheelchair'),
		select_weight_walkability_range('accidents',cnt_accidents,'wheelchair'),
		--select_weight_walkability_range('noise',noise_day::numeric,'wheelchair'),
		select_weight_walkability('parking',parking,'wheelchair')
	],
	ARRAY[
		select_full_weight_walkability('lanes','wheelchair'),
		select_full_weight_walkability('maxspeed','wheelchair'),
		select_full_weight_walkability('crossings','wheelchair'),
		select_full_weight_walkability('accidents','wheelchair'),
		--select_full_weight_walkability('noise','wheelchair'),
		select_full_weight_walkability('parking','wheelchair')
	]
),0);

UPDATE edge SET traffic_protection_wheelchair = 100
WHERE traffic_protection_wheelchair IS NULL; 

UPDATE edge
SET traffic_protection_wheelchair = (traffic_protection_wheelchair - 50) / 0.5;

UPDATE edge
SET traffic_protection_wheelchair = 0
WHERE traffic_protection_wheelchair < 0;

----##########################################################################################################################----
----#####################################################SECURITY#############################################################----
----##########################################################################################################################----

--Underpasses
UPDATE edge f 
SET covered = p.covered
FROM planet_osm_line_bbox p
WHERE f.osm_id = p.osm_id;

UPDATE edge f 
SET covered = p.tunnel
FROM planet_osm_line_bbox p
WHERE f.osm_id = p.osm_id
AND p.tunnel IS NOT NULL;

UPDATE edge f 
SET covered = 'no'
WHERE covered IS NULL;

--Illuminance
WITH variables AS 
(
    SELECT select_from_variable_container_o('lit') AS lit
)
UPDATE edge f SET lit_classified = x.lit_classified
FROM
    (SELECT f.id,
    CASE WHEN 
        lit IN ('yes','Yes','automatic','24/7','sunset-sunrise') 
        OR (lit IS NULL AND highway IN (SELECT jsonb_array_elements_text((lit ->> 'highway_yes')::jsonb) FROM variables)
			AND maxspeed<80)
        THEN 'yes' 
    WHEN
        lit IN ('no','No','disused')
        OR (lit IS NULL AND (highway IN (SELECT jsonb_array_elements_text((lit ->> 'highway_no')::jsonb) FROM variables) 
        OR surface IN (SELECT jsonb_array_elements_text((lit ->> 'surface_no')::jsonb) FROM variables)
		OR maxspeed>=80)
        )
        THEN 'no'
    ELSE 'unclassified'
    END AS lit_classified 
    FROM edge f
    ) x
WHERE f.id = x.id;

--Precalculation of visualized features for lit
DROP TABLE IF EXISTS buffer_lamps;
CREATE TABLE buffer_lamps as
SELECT ST_SUBDIVIDE((ST_DUMP(ST_UNION(ST_BUFFER(geom,15 * meter_degree())))).geom, 100) AS geom, 'yes' AS lit 
FROM street_furniture
WHERE amenity = 'street_lamp';

CREATE INDEX ON buffer_lamps USING gist(geom);

DROP TABLE IF EXISTS footpaths_lit; 
CREATE TEMP TABLE footpaths_lit AS 
SELECT DISTINCT id 
FROM edge_get_polygon_attr('buffer_lamps','lit')
WHERE arr_shares IS NOT NULL 
AND arr_polygon_attr = ARRAY['yes']
AND arr_shares[1] > 0.3; 

UPDATE edge f  
SET lit_classified = 'yes'
FROM footpaths_lit l 
WHERE f.id = l.id;

-- Score Calcuation -- STANDARD
UPDATE edge f SET security_standard = 
round(group_index(
	ARRAY[
		select_weight_walkability('lit_classified',lit_classified,'standard'),
		select_weight_walkability('covered',covered,'standard')
	],
	ARRAY[
		select_full_weight_walkability('lit_classified','standard'),
		select_full_weight_walkability('covered','standard')
	]
),0);

-- Score Calcuation -- SENIOR
UPDATE edge f SET security_senior = 
round(group_index(
	ARRAY[
		select_weight_walkability('lit_classified',lit_classified,'senior'),
		select_weight_walkability('covered',covered,'senior')
	],
	ARRAY[
		select_full_weight_walkability('lit_classified','senior'),
		select_full_weight_walkability('covered','senior')
	]
),0);

-- Score Calcuation -- CHILD
UPDATE edge f SET security_child = 
round(group_index(
	ARRAY[
		select_weight_walkability('lit_classified',lit_classified,'child'),
		select_weight_walkability('covered',covered,'child')
	],
	ARRAY[
		select_full_weight_walkability('lit_classified','child'),
		select_full_weight_walkability('covered','child')
	]
),0);

-- Score Calcuation -- WOMAN
UPDATE edge f SET security_woman = 
round(group_index(
	ARRAY[
		select_weight_walkability('lit_classified',lit_classified,'woman'),
		select_weight_walkability('covered',covered,'woman')
	],
	ARRAY[
		select_full_weight_walkability('lit_classified','woman'),
		select_full_weight_walkability('covered','woman')
	]
),0);

-- Score Calcuation -- WHEELCHAIR
UPDATE edge f SET security_wheelchair = 
round(group_index(
	ARRAY[
		select_weight_walkability('lit_classified',lit_classified,'wheelchair'),
		select_weight_walkability('covered',covered,'wheelchair')
	],
	ARRAY[
		select_full_weight_walkability('lit_classified','wheelchair'),
		select_full_weight_walkability('covered','wheelchair')
	]
),0);

----##########################################################################################################################----
----#####################################################GREEN & BLUE#############################################################----
----##########################################################################################################################----

-- start with 0

UPDATE edge f 
SET nature = 0;   
   
-- add score for trees
DROP TABLE IF EXISTS trees;
CREATE TEMP TABLE trees AS 	
SELECT geom 
FROM vegetation_points;

CREATE INDEX ON trees USING GIST(geom);

WITH cnt_table AS 
(
	SELECT f.id, COALESCE(points_sum,0) AS points_sum 
	FROM edge f 
	LEFT JOIN edge_get_points_sum('trees', 30) c
	ON f.id = c.id 	
)
UPDATE edge f
SET cnt_trees = points_sum 
FROM cnt_table c
WHERE f.id = c.id;

UPDATE edge f 
SET nature = nature + cnt_trees*20 ;   

-- add score for tree rows 
DROP TABLE IF EXISTS tree_row_buffer;
CREATE TABLE tree_row_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(v.geom,0.00015), 50) AS geom
FROM vegetation_lines v, bbox b
WHERE v.natural IN ('tree_row')
AND ST_Intersects(v.geom,b.geom); 

CREATE INDEX ON tree_row_buffer USING GIST(geom);

DROP TABLE IF EXISTS intersect_tree_row;
CREATE TEMP TABLE intersect_tree_row AS 	
SELECT e.id
FROM edge e, tree_row_buffer t
WHERE ST_Intersects(e.geom,t.geom); 

WITH intersect_tree_row AS 
(
	SELECT e.id
	FROM edge e, tree_row_buffer t
	WHERE ST_Intersects(e.geom,t.geom)
)
UPDATE edge f 
SET nature = nature + 70
FROM intersect_tree_row i
WHERE f.id = i.id;

-- add score for hedges
DROP TABLE IF EXISTS hedge_buffer;
CREATE TABLE hedge_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(v.geom,0.00015), 50) AS geom
FROM vegetation_lines v, bbox b
WHERE v.barrier IN ('hedge')
AND ST_Intersects(v.geom,b.geom); 

CREATE INDEX ON hedge_buffer USING GIST(geom);

DROP TABLE IF EXISTS intersect_hedge_buffer;
CREATE TEMP TABLE intersect_hedge_buffer AS 	
SELECT e.id
FROM edge e, hedge_buffer h
WHERE ST_Intersects(e.geom,h.geom); 

WITH intersect_hedge_buffer AS 
(
	SELECT e.id
	FROM edge e, hedge_buffer h
	WHERE ST_Intersects(e.geom,h.geom)
)
UPDATE edge f 
SET nature = nature + 20
FROM intersect_tree_row i
WHERE f.id = i.id;

-- add score for canals
DROP TABLE IF EXISTS canal_buffer;
CREATE TABLE canal_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(v.geom,0.00015), 50) AS geom
FROM vegetation_lines v, bbox b
WHERE v.waterway IN ('canal')
AND ST_Intersects(v.geom,b.geom); 

CREATE INDEX ON canal_buffer USING GIST(geom);

DROP TABLE IF EXISTS intersect_canal;
CREATE TEMP TABLE intersect_canal AS 	
SELECT e.id
FROM edge e, canal_buffer c
WHERE ST_Intersects(e.geom,c.geom); 

WITH intersect_canal AS 
(
	SELECT e.id
	FROM edge e, canal_buffer c
	WHERE ST_Intersects(e.geom,c.geom)
)
UPDATE edge f 
SET nature = nature + 20
FROM intersect_canal i
WHERE f.id = i.id;

-- add score for rivers
DROP TABLE IF EXISTS river_buffer;
CREATE TABLE river_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(v.geom,0.00050), 50) AS geom
FROM vegetation_lines v, bbox b
WHERE v.waterway IN ('river')
AND ST_Intersects(v.geom,b.geom); 

CREATE INDEX ON river_buffer USING GIST(geom);

DROP TABLE IF EXISTS intersect_river;
CREATE TEMP TABLE intersect_river AS 	
SELECT e.id
FROM edge e, river_buffer c
WHERE ST_Intersects(e.geom,c.geom); 

WITH intersect_river AS 
(
	SELECT e.id
	FROM edge e, river_buffer c
	WHERE ST_Intersects(e.geom,c.geom)
)
UPDATE edge f 
SET nature = nature + 40
FROM intersect_river i
WHERE f.id = i.id;

-- add score for scrubs
DROP TABLE IF EXISTS scrub_buffer;
CREATE TABLE scrub_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(v.geom,0.00015), 50) AS geom
FROM vegetation_polygons v, bbox b
WHERE v.natural IN ('scrub')
AND ST_Intersects(v.geom,b.geom); 

CREATE INDEX ON scrub_buffer USING GIST(geom);

DROP TABLE IF EXISTS intersect_scrub;
CREATE TEMP TABLE intersect_scrub AS 	
SELECT e.id
FROM edge e, scrub_buffer c
WHERE ST_Intersects(e.geom,c.geom); 

WITH intersect_scrub AS 
(
	SELECT e.id
	FROM edge e, scrub_buffer c
	WHERE ST_Intersects(e.geom,c.geom)
)
UPDATE edge f 
SET nature = nature + 10
FROM intersect_scrub i
WHERE f.id = i.id;


-- add score for parks
DROP TABLE IF EXISTS park_buffer;
CREATE TABLE park_buffer as
SELECT ST_SUBDIVIDE(ST_BUFFER(v.geom,0.00015), 50) AS geom
FROM vegetation_polygons v, bbox b
WHERE v.leisure IN ('park')
AND ST_Intersects(v.geom,b.geom); 

CREATE INDEX ON park_buffer USING GIST(geom);

DROP TABLE IF EXISTS intersect_park;
CREATE TEMP TABLE intersect_park AS 	
SELECT e.id
FROM edge e, park_buffer c
WHERE ST_Intersects(e.geom,c.geom); 

WITH intersect_park AS 
(
	SELECT e.id
	FROM edge e, park_buffer c
	WHERE ST_Intersects(e.geom,c.geom)
)
UPDATE edge f 
SET nature = nature + 50
FROM intersect_park i
WHERE f.id = i.id;

-- limit score to 100
UPDATE edge f 
SET nature = 100
WHERE nature > 100;



----##########################################################################################################################----
----#####################################################WALKING ENVIRONMENT##################################################----
----##########################################################################################################################----

--Classify by number of POIs
CREATE TEMP TABLE pois_to_count AS 
SELECT geom 
FROM planet_osm_point_bbox
WHERE amenity NOT IN ('parking','bench','information','parking_space','waste_basket','fountain','toilets','carging_station','bicycle_parking','parking_entrance','motorcycle_parking','hunting_stand');

CREATE INDEX ON pois_to_count USING GIST(geom);

WITH cnt_table AS 
(
	SELECT f.id, COALESCE(points_sum,0) AS points_sum, f.geom  
	FROM edge f 
	LEFT JOIN edge_get_points_sum('pois_to_count', 50) c
	ON f.id = c.id 	
), 
classify AS 
(
	SELECT c.id, string_condition 
	FROM walkability w, cnt_table c 
	WHERE attribute = 'pois'
	AND (w.min_value <= c.points_sum OR w.min_value IS NULL)  
	AND (w.max_value > c.points_sum OR w.max_value IS NULL)
)
UPDATE edge f
SET pois= c.string_condition 
FROM classify c
WHERE f.id = c.id;

DROP TABLE pois_to_count;

--Classify by number of Population
WITH cnt_table AS 
(
	SELECT id, points_sum
	FROM edge_get_points_sum('population', 50, 'population') c
),
percentiles AS 
(
	SELECT id, points_sum, ntile(4) over (order by points_sum) AS percentile
	FROM cnt_table 
	WHERE points_sum <> 0 
	AND points_sum IS NOT NULL 
),
combined AS 
(
	SELECT f.id, (COALESCE(p.percentile,0) + 1) AS arr_index 
	FROM edge f 
	LEFT JOIN percentiles p 
	ON f.id = p.id 
)
UPDATE edge f
SET population = (ARRAY['no','low','medium','high','very_high'])[arr_index] 
FROM combined c 
WHERE f.id = c.id; 


--Landuse
DO $$
	DECLARE 
    	buffer float := meter_degree() * 50;
    BEGIN 
		
	    DROP TABLE IF EXISTS landuse_arrays; 
	    CREATE TABLE landuse_arrays AS 
	    WITH landuse_footpath AS 
	    (
			SELECT ARRAY_AGG(landuse_simplified) AS landuse, id 
			FROM edge f, landuse_osm l
			WHERE ST_DWITHIN(f.geom, l.geom, buffer)
			AND ST_AREA(l.geom::geography) > 500
			GROUP BY id 
		)
		SELECT f.id, ARRAY_AGG(l.landuse) AS landuse 
		FROM landuse_footpath f, 
		LATERAL (SELECT DISTINCT landuse FROM UNNEST(landuse) landuse WHERE landuse IS NOT NULL) l   
		GROUP BY f.id; 
		
		ALTER TABLE landuse_arrays ADD PRIMARY KEY (id);
		UPDATE edge f  
		SET landuse = l.landuse 
		FROM landuse_arrays l 
		WHERE f.id = l.id;
		
		DROP TABLE IF EXISTS landuse_penalty; 
		CREATE TABLE landuse_penalty AS 
		SELECT landuse_simplified landuse, ST_SUBDIVIDE(ST_BUFFER(geom, buffer)::geometry, 50) AS geom 
		FROM landuse_osm l ;	
		CREATE INDEX ON landuse_penalty USING GIST(geom);
	
	END; 
$$;

DROP TABLE IF EXISTS penalty_shares; 
CREATE TABLE penalty_shares AS 
WITH landuse_shares AS 
(
	SELECT *, ARRAY_LENGTH(arr_polygon_attr, 1) AS len_array
	FROM edge_get_polygon_attr('landuse_penalty','landuse')
	WHERE arr_polygon_attr IS NOT NULL 
),
landuse_values AS 
(
	SELECT id, AVG(a.shares * w.value)
	FROM landuse_shares s, walkability w, 
	LATERAL (SELECT UNNEST(s.arr_polygon_attr) AS landuse, UNNEST(s.arr_shares) AS shares) a
	WHERE arr_polygon_attr IS NOT NULL
	AND w."attribute" = 'landuse'
	AND w.string_condition = a.landuse
	GROUP BY id 
),
share_other_landuse AS 
(
	SELECT x.id, CASE 
	WHEN sum(x.shares) = 0 THEN 1
	WHEN sum(x.shares) < 1 THEN (1-sum(x.shares)) 
	ELSE 0 END AS share_other  
	FROM (SELECT id, UNNEST(arr_shares) AS shares FROM landuse_shares l) x  
	GROUP BY id 
)
SELECT v.id, avg + (o.share_other * 100/s.len_array ) AS value
FROM landuse_values v
LEFT JOIN landuse_shares s
ON v.id = s.id
LEFT JOIN share_other_landuse o 
ON v.id = o.id; 

CREATE INDEX ON penalty_shares (id);

-- calculate score -- STANDARD
WITH landuse_values AS 
(
	SELECT f.id, COALESCE(p.value, 100) * (SELECT DISTINCT weight_standard FROM walkability WHERE ATTRIBUTE = 'landuse') AS value 
	FROM edge f
	LEFT JOIN penalty_shares p 
	ON f.id = p.id 	
)
UPDATE edge f SET liveliness_standard = 
round(group_index(
	ARRAY[
		l.value::NUMERIC, 
		select_weight_walkability('population',population,'standard'),
		select_weight_walkability_range('nature',nature,'standard'),
		select_weight_walkability('pois',pois,'standard')
	],
	ARRAY[
		select_full_weight_walkability('landuse','standard'),
		select_full_weight_walkability('population','standard'),
		select_full_weight_walkability('nature','standard'),
		select_full_weight_walkability('pois','standard')
	]
),0)
FROM landuse_values l 
WHERE f.id = l.id;

-- calculate score -- SENIOR
WITH landuse_values AS 
(
	SELECT f.id, COALESCE(p.value, 100) * (SELECT DISTINCT weight_senior FROM walkability WHERE ATTRIBUTE = 'landuse') AS value 
	FROM edge f
	LEFT JOIN penalty_shares p 
	ON f.id = p.id 	
)
UPDATE edge f SET liveliness_senior = 
round(group_index(
	ARRAY[
		l.value::NUMERIC, 
		select_weight_walkability('population',population,'senior'),
		select_weight_walkability_range('nature',nature,'senior'),
		select_weight_walkability('pois',pois,'senior')
	],
	ARRAY[
		select_full_weight_walkability('landuse','senior'),
		select_full_weight_walkability('population','senior'),
		select_full_weight_walkability('nature','senior'),
		select_full_weight_walkability('pois','senior')
	]
),0)
FROM landuse_values l 
WHERE f.id = l.id;

-- calculate score -- CHILD
WITH landuse_values AS 
(
	SELECT f.id, COALESCE(p.value, 100) * (SELECT DISTINCT weight_child FROM walkability WHERE ATTRIBUTE = 'landuse') AS value 
	FROM edge f
	LEFT JOIN penalty_shares p 
	ON f.id = p.id 	
)
UPDATE edge f SET liveliness_child = 
round(group_index(
	ARRAY[
		l.value::NUMERIC, 
		select_weight_walkability('population',population,'child'),
		select_weight_walkability_range('nature',nature,'child'),
		select_weight_walkability('pois',pois,'child')
	],
	ARRAY[
		select_full_weight_walkability('landuse','child'),
		select_full_weight_walkability('population','child'),
		select_full_weight_walkability('nature','child'),
		select_full_weight_walkability('pois','child')
	]
),0)
FROM landuse_values l  
WHERE f.id = l.id;

-- calculate score -- WHEELCHAIR
WITH landuse_values AS 
(
	SELECT f.id, COALESCE(p.value, 100) * (SELECT DISTINCT weight_wheelchair FROM walkability WHERE ATTRIBUTE = 'landuse') AS value 
	FROM edge f
	LEFT JOIN penalty_shares p 
	ON f.id = p.id 	
)
UPDATE edge f SET liveliness_wheelchair = 
round(group_index(
	ARRAY[
		l.value::NUMERIC, 
		select_weight_walkability('population',population,'wheelchair'),
		select_weight_walkability_range('nature',nature,'wheelchair'),
		select_weight_walkability('pois',pois,'wheelchair')
	],
	ARRAY[
		select_full_weight_walkability('landuse','wheelchair'),
		select_full_weight_walkability('population','wheelchair'),
		select_full_weight_walkability('nature','wheelchair'),
		select_full_weight_walkability('pois','wheelchair')
	]
),0)
FROM landuse_values l  
WHERE f.id = l.id;

-- calculate score -- WOMAN
WITH landuse_values AS 
(
	SELECT f.id, COALESCE(p.value, 100) * (SELECT DISTINCT weight_woman FROM walkability WHERE ATTRIBUTE = 'landuse') AS value 
	FROM edge f
	LEFT JOIN penalty_shares p 
	ON f.id = p.id 	
)
UPDATE edge f SET liveliness_woman = 
round(group_index(
	ARRAY[
		l.value::NUMERIC, 
		select_weight_walkability('population',population,'woman'),
		select_weight_walkability_range('nature',nature,'woman'),
		select_weight_walkability('pois',pois,'woman')
	],
	ARRAY[
		select_full_weight_walkability('landuse','woman'),
		select_full_weight_walkability('population','woman'),
		select_full_weight_walkability('nature','woman'),
		select_full_weight_walkability('pois','woman')
	]
),0)
FROM landuse_values l  
WHERE f.id = l.id;

----##########################################################################################################################----
----###########################################################URBAN EQUIPMENT########################################################----
----##########################################################################################################################----

-- Benches
-- Create temp table to count benches
DROP TABLE IF EXISTS benches;
CREATE TEMP TABLE benches AS 	
SELECT geom 
FROM street_furniture 
WHERE amenity = 'bench';
CREATE INDEX ON benches USING GIST(geom);

WITH cnt_table AS 
(
	SELECT f.id, COALESCE(points_sum,0) AS points_sum 
	FROM edge f 
	LEFT JOIN edge_get_points_sum('benches', 30) c
	ON f.id = c.id 	
)
UPDATE edge f
SET cnt_benches = points_sum 
FROM cnt_table c
WHERE f.id = c.id;

--- Waste-baskets
DROP TABLE IF EXISTS waste_baskets;
CREATE TEMP TABLE waste_baskets AS 
SELECT geom 
FROM street_furniture 
WHERE amenity = 'waste_basket';
CREATE INDEX ON waste_baskets USING GIST(geom);

WITH cnt_table AS 
(
	SELECT f.id, COALESCE(points_sum,0) AS points_sum 
	FROM edge f 
	LEFT JOIN edge_get_points_sum('waste_baskets', 20) c
	ON f.id = c.id 	
)
UPDATE edge f
SET cnt_waste_baskets = points_sum 
FROM cnt_table c
WHERE f.id = c.id;

--- Fountains
DROP TABLE IF EXISTS fountains;
CREATE TEMP TABLE fountains AS 
SELECT geom 
FROM street_furniture 
WHERE amenity IN ('fountain','drinking_water');
CREATE INDEX ON fountains USING GIST(geom);

WITH cnt_table AS 
(
	SELECT f.id, COALESCE(points_sum,0) AS points_sum 
	FROM edge f 
	LEFT JOIN edge_get_points_sum('fountains', 50) c
	ON f.id = c.id 	
)
UPDATE edge f
SET cnt_fountains = points_sum 
FROM cnt_table c
WHERE f.id = c.id;

--- Bathrooms
DROP TABLE IF EXISTS toilets;
CREATE TEMP TABLE toilets AS 
SELECT geom 
FROM street_furniture 
WHERE amenity IN ('toilets');
CREATE INDEX ON toilets USING GIST(geom);

WITH cnt_table AS 
(
	SELECT f.id, COALESCE(points_sum,0) AS points_sum 
	FROM edge f 
	LEFT JOIN edge_get_points_sum('toilets', 300) c
	ON f.id = c.id 	
)
UPDATE edge f
SET cnt_toilets = points_sum 
FROM cnt_table c
WHERE f.id = c.id;

-- calculate score -- STANDARD
UPDATE edge f SET urban_equipment_standard = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('bench',cnt_benches,'standard'), 
		select_weight_walkability_range('waste_basket',cnt_waste_baskets,'standard'),
		select_weight_walkability_range('toilets',cnt_toilets,'standard'),
		select_weight_walkability_range('drinking_fountain',cnt_fountains,'standard')
	],
	ARRAY[
		select_full_weight_walkability('bench','standard'),
		select_full_weight_walkability('waste_basket','standard'),
		select_full_weight_walkability('toilets','standard'),
		select_full_weight_walkability('drinking_fountain','standard')
	]
),0);

UPDATE edge f 
SET urban_equipment_standard = 100 
WHERE urban_equipment_standard > 100;

--- Street furniture sum - SENIOR
UPDATE edge f SET urban_equipment_senior = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('bench',cnt_benches,'senior'), 
		select_weight_walkability_range('waste_basket',cnt_waste_baskets,'senior'),
		select_weight_walkability_range('toilets',cnt_toilets,'senior'),
		select_weight_walkability_range('drinking_fountain',cnt_fountains,'senior')
	],
	ARRAY[
		select_full_weight_walkability('bench','senior'),
		select_full_weight_walkability('waste_basket','senior'),
		select_full_weight_walkability('toilets','senior'),
		select_full_weight_walkability('drinking_fountain','senior')
	]
),0);

UPDATE edge f 
SET urban_equipment_senior = 100 
WHERE urban_equipment_senior > 100;

--- Street furniture sum - CHILD
UPDATE edge f SET urban_equipment_child = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('bench',cnt_benches,'child'), 
		select_weight_walkability_range('waste_basket',cnt_waste_baskets,'child'),
		select_weight_walkability_range('toilets',cnt_toilets,'child'),
		select_weight_walkability_range('drinking_fountain',cnt_fountains,'child')
	],
	ARRAY[
		select_full_weight_walkability('bench','child'),
		select_full_weight_walkability('waste_basket','child'),
		select_full_weight_walkability('toilets','child'),
		select_full_weight_walkability('drinking_fountain','child')
	]
),0);

UPDATE edge f 
SET urban_equipment_child = 100 
WHERE urban_equipment_child > 100;

UPDATE edge f 
SET urban_equipment_child = 0 
WHERE urban_equipment_child IS NULL;

--- Street furniture sum - WOMAN
UPDATE edge f SET urban_equipment_woman = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('bench',cnt_benches,'woman'), 
		select_weight_walkability_range('waste_basket',cnt_waste_baskets,'woman'),
		select_weight_walkability_range('toilets',cnt_toilets,'woman'),
		select_weight_walkability_range('drinking_fountain',cnt_fountains,'woman')
	],
	ARRAY[
		select_full_weight_walkability('bench','woman'),
		select_full_weight_walkability('waste_basket','woman'),
		select_full_weight_walkability('toilets','woman'),
		select_full_weight_walkability('drinking_fountain','woman')
	]
),0);

UPDATE edge f 
SET urban_equipment_woman = 100 
WHERE urban_equipment_woman > 100;

UPDATE edge f 
SET urban_equipment_woman = 0 
WHERE urban_equipment_woman IS NULL;

--- Street furniture sum - WHEELCHAIR 
UPDATE edge f SET urban_equipment_wheelchair = 
round(group_index(
	ARRAY[
		select_weight_walkability_range('bench',cnt_benches,'wheelchair'), 
		select_weight_walkability_range('waste_basket',cnt_waste_baskets,'wheelchair'),
		select_weight_walkability_range('toilets',cnt_toilets,'wheelchair'),
		select_weight_walkability_range('drinking_fountain',cnt_fountains,'wheelchair')
	],
	ARRAY[
		select_full_weight_walkability('bench','wheelchair'),
		select_full_weight_walkability('waste_basket','wheelchair'),
		select_full_weight_walkability('toilets','wheelchair'),
		select_full_weight_walkability('drinking_fountain','wheelchair')
	]
),0);

UPDATE edge f 
SET urban_equipment_wheelchair = 100 
WHERE urban_equipment_wheelchair > 100;

UPDATE edge f 
SET urban_equipment_wheelchair = 0 
WHERE urban_equipment_wheelchair IS NULL;

----##########################################################################################################################----
----###########################################################WALKABILITY INDEX########################################################----
----##########################################################################################################################----

-- calcualtion -- STANDARD
WITH weighting AS
(
	SELECT id, CASE WHEN urban_equipment_standard IS NULL THEN 0 ELSE 0.04 END AS urban_equipment_weight,
	CASE WHEN security_standard IS NULL THEN 0 ELSE 0.14 END AS security_weight,
	CASE WHEN traffic_protection_standard IS NULL THEN 0 ELSE 0.22 END AS traffic_protection_weight,
	CASE WHEN sidewalk_quality_standard IS NULL THEN 0 ELSE 0.28 END AS sidewalk_quality_weight,
	CASE WHEN liveliness_standard IS NULL THEN 0 ELSE 0.10 END AS liveliness_weight     
	FROM edge 
)
UPDATE edge f
SET walkability_standard = 
round(
	((security_standard*security_weight) + (traffic_protection_standard*traffic_protection_weight) + (sidewalk_quality_standard*sidewalk_quality_weight) + (liveliness_standard*liveliness_weight) + (urban_equipment_standard*urban_equipment_weight))
	/
	(security_weight + traffic_protection_weight + sidewalk_quality_weight + liveliness_weight + urban_equipment_weight)
,0) 
FROM weighting w 
WHERE f.id = w.id; 

UPDATE edge f 
SET data_quality = (22-num_nulls(sidewalk,incline_percent,surface,highway,lanes_impact,maxspeed,cnt_crossings,parking,
cnt_accidents,--noise_day,noise_night,
lit_classified,covered,--vegetation,water,
--population,pois,landuse,
cnt_benches,cnt_waste_baskets,cnt_fountains,cnt_toilets))::float/22.0;

UPDATE edge 
SET walkability_standard = (walkability_standard - 30) / 0.7;

UPDATE edge 
SET walkability_standard = 1 
WHERE walkability_standard < 1;

UPDATE edge 
SET walkability_standard = 1 
WHERE walkability_standard IS NULL;

UPDATE edge 
SET walkability_standard = 100 
WHERE walkability_standard > 100;

UPDATE edge 
SET impedance_walkability_standard = length_m*(50/walkability_standard::float);

-- calcualtion -- SENIOR
WITH weighting AS
(
	SELECT id, CASE WHEN urban_equipment_senior IS NULL THEN 0 ELSE 0.025 END AS urban_equipment_weight,
	CASE WHEN security_senior IS NULL THEN 0 ELSE 0.135 END AS security_weight,
	CASE WHEN traffic_protection_senior IS NULL THEN 0 ELSE 0.303 END AS traffic_protection_weight,
	CASE WHEN sidewalk_quality_senior IS NULL THEN 0 ELSE 0.502 END AS sidewalk_quality_weight,
	CASE WHEN liveliness_senior IS NULL THEN 0 ELSE 0.035 END AS liveliness_weight     
	FROM edge 
)
UPDATE edge f
SET walkability_senior = 
round(
	((security_senior*security_weight) + (traffic_protection_senior*traffic_protection_weight) + (sidewalk_quality_senior*sidewalk_quality_weight) + (liveliness_senior*liveliness_weight) + (urban_equipment_senior*urban_equipment_weight))
	/
	(security_weight + traffic_protection_weight + sidewalk_quality_weight + liveliness_weight + urban_equipment_weight)
,0) 
FROM weighting w 
WHERE f.id = w.id; 

UPDATE edge 
SET walkability_senior = (walkability_senior - 40) / 0.60;

UPDATE edge 
SET walkability_senior = 1 
WHERE walkability_senior < 1;

UPDATE edge 
SET walkability_senior = 1 
WHERE walkability_senior IS NULL;

UPDATE edge 
SET walkability_senior = 100 
WHERE walkability_senior > 100;

UPDATE edge 
SET impedance_walkability_senior = length_m*(50/walkability_senior::float);

-- calcualtion -- CHILD
WITH weighting AS
(
	SELECT id, CASE WHEN urban_equipment_child IS NULL THEN 0 ELSE 0 END AS urban_equipment_weight,
	CASE WHEN security_child IS NULL THEN 0 ELSE 0.066 END AS security_weight,
	CASE WHEN traffic_protection_child IS NULL THEN 0 ELSE 0.454 END AS traffic_protection_weight,
	CASE WHEN sidewalk_quality_child IS NULL THEN 0 ELSE 0.297 END AS sidewalk_quality_weight,
	CASE WHEN liveliness_child IS NULL THEN 0 ELSE 0.183 END AS liveliness_weight     
	FROM edge 
)
UPDATE edge f
SET walkability_child = 
round(
	((security_child*security_weight) + (traffic_protection_child*traffic_protection_weight) + (sidewalk_quality_child*sidewalk_quality_weight) + (liveliness_child*liveliness_weight) + (urban_equipment_child*urban_equipment_weight))
	/
	(security_weight + traffic_protection_weight + sidewalk_quality_weight + liveliness_weight + urban_equipment_weight)
,0) 
FROM weighting w 
WHERE f.id = w.id; 

UPDATE edge 
SET walkability_child = (walkability_child - 40) / 0.60;

UPDATE edge 
SET walkability_child = 1 
WHERE walkability_child < 1;

UPDATE edge 
SET walkability_child = 1 
WHERE walkability_child IS NULL;

UPDATE edge 
SET walkability_child = 100 
WHERE walkability_child > 100;

UPDATE edge 
SET impedance_walkability_child = length_m*(50/walkability_child::float);

-- calcualtion -- WOMAN
WITH weighting AS
(
	SELECT id, CASE WHEN urban_equipment_woman IS NULL THEN 0 ELSE 0.024 END AS urban_equipment_weight,
	CASE WHEN security_woman IS NULL THEN 0 ELSE 0.208 END AS security_weight,
	CASE WHEN traffic_protection_woman IS NULL THEN 0 ELSE 0.138 END AS traffic_protection_weight,
	CASE WHEN sidewalk_quality_woman IS NULL THEN 0 ELSE 0.279 END AS sidewalk_quality_weight,
	CASE WHEN liveliness_woman IS NULL THEN 0 ELSE 0.351 END AS liveliness_weight     
	FROM edge 
)
UPDATE edge f
SET walkability_woman = 
round(
	((security_woman*security_weight) + (traffic_protection_woman*traffic_protection_weight) + (sidewalk_quality_woman*sidewalk_quality_weight) + (liveliness_woman*liveliness_weight) + (urban_equipment_woman*urban_equipment_weight))
	/
	(security_weight + traffic_protection_weight + sidewalk_quality_weight + liveliness_weight + urban_equipment_weight)
,0) 
FROM weighting w 
WHERE f.id = w.id; 

UPDATE edge 
SET walkability_woman = (walkability_woman - 40) / 0.60;

UPDATE edge 
SET walkability_woman = 1 
WHERE walkability_woman < 1;

UPDATE edge 
SET walkability_woman = 1 
WHERE walkability_woman IS NULL;

UPDATE edge 
SET walkability_woman = 100 
WHERE walkability_woman > 100;

UPDATE edge 
SET impedance_walkability_woman = length_m*(50/walkability_woman::float);

-- calcualtion -- WHEELCHAIR
WITH weighting AS
(
	SELECT id, CASE WHEN urban_equipment_wheelchair IS NULL THEN 0 ELSE 0.031 END AS urban_equipment_weight,
	CASE WHEN security_wheelchair IS NULL THEN 0 ELSE 0.063 END AS security_weight,
	CASE WHEN traffic_protection_wheelchair IS NULL THEN 0 ELSE 0.119 END AS traffic_protection_weight,
	CASE WHEN sidewalk_quality_wheelchair IS NULL THEN 0 ELSE 0.742 END AS sidewalk_quality_weight,
	CASE WHEN liveliness_wheelchair IS NULL THEN 0 ELSE 0.045 END AS liveliness_weight     
	FROM edge 
)
UPDATE edge f
SET walkability_wheelchair = 
round(
	((security_wheelchair*security_weight) + (traffic_protection_wheelchair*traffic_protection_weight) + (sidewalk_quality_wheelchair*sidewalk_quality_weight) + (liveliness_wheelchair*liveliness_weight) + (urban_equipment_wheelchair*urban_equipment_weight))
	/
	(security_weight + traffic_protection_weight + sidewalk_quality_weight + liveliness_weight + urban_equipment_weight)
,0) 
FROM weighting w 
WHERE f.id = w.id; 

UPDATE edge 
SET walkability_wheelchair = (walkability_wheelchair - 40) / 0.60;

UPDATE edge 
SET walkability_wheelchair = 1 
WHERE walkability_wheelchair < 1;

UPDATE edge 
SET walkability_wheelchair = 1 
WHERE walkability_wheelchair IS NULL;

UPDATE edge 
SET walkability_wheelchair = 100 
WHERE walkability_wheelchair > 100;

UPDATE edge 
SET impedance_walkability_wheelchair = length_m*(50/walkability_wheelchair::float);