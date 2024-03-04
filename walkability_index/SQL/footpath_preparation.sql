/*Defines maxspeed based on neighboring links and assumption per highway category.*/
DROP TABLE IF EXISTS edge_maxspeed; 
CREATE TEMP TABLE edge_maxspeed AS 
SELECT w.id, w.highway, w.source, w.target, w.maxspeed_forward, 
CASE WHEN (p.tags -> 'maxspeed')~E'^\\d+$' THEN (p.tags -> 'maxspeed')::integer ELSE NULL END AS maxspeed, w.geom   
FROM augsburg.edge w, augsburg.planet_osm_line_bbox p 
WHERE maxspeed_forward IS NOT NULL
AND w.osm_id = p.osm_id; 

ALTER TABLE edge_maxspeed ADD PRIMARY KEY(id);
CREATE INDEX ON edge_maxspeed (source); 
CREATE INDEX ON edge_maxspeed (target); 


DROP TABLE IF EXISTS maxspeed_not_defined;
CREATE TEMP TABLE maxspeed_not_defined AS 
SELECT DISTINCT w2.id, w2.highway, w2.source, w2.target, w2.maxspeed, w2.geom
FROM edge_maxspeed w2 
WHERE w2.maxspeed IS NULL 
AND w2.highway IN ('motorway','motorway_link','primary','primary_link','secondary','secondary_link','trunk','trunk_link','tertiary','tertiary_link','residential','service','unclassified');

ALTER TABLE maxspeed_not_defined ADD PRIMARY KEY(id);
CREATE INDEX ON maxspeed_not_defined (source); 
CREATE INDEX ON maxspeed_not_defined (target); 

DROP TABLE IF EXISTS maxspeed_complemented;
CREATE TEMP TABLE maxspeed_complemented
(
	id integer,
	highway TEXT,
	source integer,
	target integer, 
	maxspeed integer,
	geom geometry
);

DO $$
	DECLARE 
		way_id integer;
		cnt integer := 0;
	BEGIN 
		
		DROP TABLE IF EXISTS result_recursive;
		CREATE TABLE result_recursive
		(
			id integer,
			highway TEXT,
			source integer,
			target integer, 
			maxspeed integer,
			geom geometry
		);

		FOR way_id IN 
		SELECT DISTINCT w1.id
		FROM edge_maxspeed w1, edge_maxspeed w2 
		WHERE w1.maxspeed IS NOT NULL 
		AND w2.maxspeed IS NULL 
		AND w1.highway IN ('motorway','motorway_link','primary','primary_link','secondary','secondary_link','trunk','trunk_link','tertiary','tertiary_link','residential','service','unclassified')
		AND w2.highway IN ('motorway','motorway_link','primary','primary_link','secondary','secondary_link','trunk','trunk_link','tertiary','tertiary_link','residential','service','unclassified')
		AND (
			(w1.source = w2.source OR w1.target = w2.target)
			OR 
			(w1.source = w2.target OR w1.target = w2.source)
		)		
		LOOP 
		
			cnt = cnt + 1;
			IF (SELECT count(*) FROM (SELECT * FROM maxspeed_not_defined LIMIT 1) x) = 0 THEN
				EXIT;
			END IF; 
	
			TRUNCATE result_recursive; 
			INSERT INTO result_recursive
			WITH RECURSIVE subordinates AS (
				SELECT id, highway, source, target, maxspeed, geom
				FROM edge_maxspeed 
				WHERE id = way_id
				UNION
				SELECT w.id, w.highway, w.source, w.target, s.maxspeed, w.geom
				FROM maxspeed_not_defined w, subordinates s
				WHERE s.highway = w.highway
				AND 
				(
					(s.source = w.source OR s.target = w.target)
					OR 
					(s.source = w.target OR s.target = w.source)
				)
			) 
			SELECT *
			FROM subordinates;
				
			DELETE FROM maxspeed_not_defined n
			USING result_recursive r
			WHERE n.id = r.id; 
		
			INSERT INTO maxspeed_complemented 
			SELECT * 
			FROM result_recursive; 
		END LOOP; 
		DROP TABLE result_recursive;
	END; 
$$;

ALTER TABLE maxspeed_complemented ADD PRIMARY KEY(id);

DO $$
	DECLARE 
		backup_speed_classification jsonb := '{
			"path": 5,
			"track": 10,
			"steps": 0,
			"residential": 30,
			"motorway": 130,
			"motorway_link": 80,
			"trunk": 100,
			"trunk_link": 80,
			"footway": 5,
		    "pedestrian": 5,
			"living_street": 7
		}'::jsonb; 
	BEGIN 
		DROP TABLE IF EXISTS classified_maxspeed;
		CREATE TEMP TABLE classified_maxspeed AS 
		SELECT w.id, w.highway, 
		CASE WHEN c.maxspeed IS NOT NULL THEN c.maxspeed 
		WHEN w.maxspeed IS NULL THEN (backup_speed_classification ->> w.highway)::integer
		ELSE w.maxspeed END AS maxspeed, w.geom  
		FROM edge_maxspeed w
		LEFT JOIN maxspeed_complemented c  
		ON w.id = c.id; 
		ALTER TABLE classified_maxspeed ADD PRIMARY KEY(id);
		
		UPDATE edge w
		SET maxspeed_forward = c.maxspeed
		FROM classified_maxspeed c
		WHERE c.id = w.id; 
	END; 
$$;


-- --Table for visualization of the footpath quality
DROP TABLE IF EXISTS footpath_visualization;
CREATE TABLE footpath_visualization 
(
	id serial, 
	edge_id bigint,
	osm_id bigint,
	length_m float,
	width jsonb,
	maxspeed integer, 
	incline_percent float, 
	lanes integer,
	noise_day float, 
	noise_night float, 
	lit text,
	lit_classified text, 
	parking text, 
	segregated text, 
	sidewalk TEXT,
	smoothness text, 
	highway text, 
	surface text, 
	covered text,
	wheelchair text, 
	wheelchair_classified text, 
	cnt_crossings integer, 
	cnt_accidents integer, 
	cnt_benches integer, 
	cnt_waste_baskets integer,
	cnt_fountains integer, 
	cnt_toilets integer,
	population text, 
	pois text, 
	landuse text[],
	vegetation integer, 
	water integer,
	street_furniture integer,  
	sidewalk_quality_standard integer,
	sidewalk_quality_senior integer,
	sidewalk_quality_child integer,
	sidewalk_quality_woman integer,
	sidewalk_quality_wheelchair integer,
	traffic_protection_standard integer, 
	traffic_protection_senior integer, 
	traffic_protection_child integer, 
	traffic_protection_woman integer, 
	traffic_protection_wheelchair integer, 
	security_standard integer, 
	security_senior integer, 
	security_child integer, 
	security_woman integer, 
	security_wheelchair integer, 
	liveliness_standard integer,
	liveliness_senior integer,
	liveliness_child integer,
	liveliness_woman integer,
	liveliness_wheelchair integer,
	urban_equipment_standard integer,
	urban_equipment_senior integer,
	urban_equipment_child integer,
	urban_equipment_woman integer,
	urban_equipment_wheelchair integer,
	walkability_standard integer, 
	walkability_senior integer, 
	walkability_child integer, 
	walkability_woman integer, 
	walkability_wheelchair integer,
	data_quality float,
	geom geometry,
	CONSTRAINT footpath_visualization_pkey PRIMARY KEY(id)
);

INSERT INTO footpath_visualization(edge_id, osm_id, length_m, geom, sidewalk, width, highway, maxspeed, incline_percent, 
lanes, lit, lit_classified, parking, segregated, smoothness, surface, wheelchair, wheelchair_classified)
SELECT id, osm_id, ST_LENGTH(geom::geography), geom, w.sidewalk,
CASE WHEN w.sidewalk_left_width IS NOT NULL OR w.sidewalk_right_width IS NOT NULL OR w.sidewalk_both_width IS NOT NULL 
THEN jsonb_build_object('sidewalk_left_width',sidewalk_left_width, 'sidewalk_right_width', sidewalk_right_width, 'sidewalk_both_width', sidewalk_both_width) 
WHEN w.width IS NOT NULL THEN jsonb_build_object('width', width) 
ELSE NULL
END AS width, highway, maxspeed_forward, incline_percent, lanes, lit, lit_classified, parking, 
segregated, smoothness, surface, wheelchair, wheelchair_classified
FROM edge w
WHERE w.class_id::text NOT IN (SELECT UNNEST(select_from_variable_container('excluded_class_id_walking'))) 
AND (
	w.foot NOT IN (SELECT UNNEST(select_from_variable_container('categories_no_foot'))) 
	OR w.foot IS NULL 
)
AND highway IS NOT NULL;

CREATE INDEX ON footpath_visualization USING gist(geom);

WITH clipped_footpaths AS 
(
    SELECT f.id, ST_Intersection(f.geom, b.geom) AS geom 
    FROM footpath_visualization f, bbox b 
    WHERE ST_Intersects(f.geom, ST_Boundary(b.geom)) 
)

UPDATE footpath_visualization f
SET geom = c.geom 
FROM clipped_footpaths c 
WHERE f.id = c.id; 


WITH to_delete AS 
(
    SELECT f.id
    FROM footpath_visualization f
    LEFT JOIN bbox b ON ST_Intersects(f.geom, b.geom)
    WHERE b.id IS NULL 
)
DELETE FROM footpath_visualization f 
USING to_delete d
WHERE f.id = d.id;

-- --Table for visualization of parking
DROP TABLE IF EXISTS parking;
CREATE TABLE parking AS
	SELECT (ST_OffsetCurve(w.geom,  0.00005, 'join=round mitre_limit=2.0')) AS geom, 
		w.parking,
			CASE WHEN w.parking_lane_left IS NOT NULL 
				THEN w.parking_lane_left
			WHEN w.parking_lane_both IS NOT NULL 
				THEN w.parking_lane_both
			ELSE NULL
			END AS parking_lane, 
		highway
	FROM edge w
	WHERE (w.parking_lane_left IS NOT NULL OR w.parking_lane_both IS NOT NULL)
UNION
	SELECT (ST_OffsetCurve(w.geom,  -0.00005, 'join=round mitre_limit=2.0')) AS geom, 
		w.parking,
			CASE WHEN w.parking_lane_right IS NOT NULL 
				THEN w.parking_lane_right
			WHEN w.parking_lane_both IS NOT NULL 
				THEN w.parking_lane_both
			ELSE NULL
			END AS parking_lane, 
		highway
	FROM edge w
	WHERE (w.parking_lane_right IS NOT NULL OR w.parking_lane_both IS NOT NULL)
UNION
	SELECT (ST_OffsetCurve(w.geom,  0.00005, 'join=round mitre_limit=2.0')), w.parking, 'no' AS parking_lane, w.highway FROM edge w
	WHERE w.parking = 'no'
UNION
	SELECT (ST_OffsetCurve(w.geom,  -0.00005, 'join=round mitre_limit=2.0')), w.parking, 'no' AS parking_lane, w.highway FROM edge w
	WHERE w.parking = 'no'
UNION
	SELECT geom, parking, NULL AS parking_lane, highway FROM edge
	WHERE parking IS NULL AND parking_lane_right IS NULL AND parking_lane_left IS NULL AND parking_lane_both IS NULL
	AND highway IN ('secondary','tertiary','residential','living_street','service','unclassified');
