-- Load walkability table 
--DROP TABLE IF EXISTS walkability;
--CREATE TABLE walkability(
--	category varchar,
--	criteria varchar,
--	attribute varchar,
--	string_condition varchar,
--	min_value numeric,
--	max_value numeric,
--	value numeric,
--	weight_standard numeric,
--	weight_senior numeric,
--	weight_child numeric,
--	weight_woman numeric,
--	weight_wheelchair numeric
--);

--COPY walkability
--FROM '/opt/data_preparation//walkability.csv'
--DELIMITER ';'
--CSV HEADER;

--ALTER TABLE walkability ADD COLUMN gid serial;
--ALTER TABLE walkability ADD PRIMARY KEY(gid);

DROP FUNCTION IF EXISTS select_full_weight_walkability;
CREATE OR REPLACE FUNCTION select_full_weight_walkability(attribute_input text, user_input text)
RETURNS numeric AS
$$
	SELECT 
	CASE 
		WHEN user_input = 'senior' THEN w.weight_senior
		WHEN user_input = 'child' THEN w.weight_child
		WHEN user_input = 'woman' THEN w.weight_woman
		WHEN user_input = 'wheelchair' THEN w.weight_wheelchair
		ELSE w.weight_standard
		END AS weight
	FROM walkability w 
	WHERE w.attribute = attribute_input 

$$
LANGUAGE sql immutable;