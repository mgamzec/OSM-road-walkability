DROP FUNCTION IF EXISTS select_weight_walkability_range;
CREATE OR REPLACE FUNCTION select_weight_walkability_range(attribute_input text, condition_input float8, user_input text)
RETURNS numeric AS
$$
	SELECT 
		CASE 
		WHEN user_input = 'senior' THEN (w.value*w.weight_senior)
		WHEN user_input = 'child' THEN (w.value*w.weight_child)
		WHEN user_input = 'woman' THEN (w.value*w.weight_woman)
		WHEN user_input = 'wheelchair' THEN (w.value*w.weight_wheelchair)
		ELSE (w.value*w.weight_standard)
		END AS weight
	FROM walkability w
	WHERE w.attribute = attribute_input
	AND (w.min_value < condition_input or w.min_value IS NULL)
	AND (w.max_value >= condition_input or w.max_value IS NULL) 
$$
LANGUAGE sql immutable;