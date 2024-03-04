--VARIABLE_CONTAINER--

drop table if exists variable_container;
create table variable_container (
	identifier varchar(100) not NULL,
	variable_simple text,
	variable_array _text,
	variable_object jsonb);
 
[12:08] Ulrike Jehle
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('heatmap_sensitivities',NULL,'{150000,200000,250000,300000,350000,400000,450000}',NULL),
	 ('pois_one_entrance',NULL,'{kindergarten,nursery,primary_school,secondary_school,grundschule,hauptschule,realschule,werkrealschule,gymnasium,bar,biergarten,cafe,pub,fast_food,ice_cream,restaurant,theatre,sum_population,cinema,library,nightclub,recycling,car_sharing,bicycle_rental,cargo_bike,charging_station,bus_station,tram_station,subway_station,railway_station,taxi,hairdresser,atm,bank,dentist,doctors,pharmacy,post_box,post_office,fuel,garden,newsagent,townhall,government,arts_centre,bicycle,bakery,butcher,clothes,convenience,general,fashion,florist,greengrocer,kiosk,mall,shoes,sports,supermarket,health_food,discount_supermarket,hospital,clinic,community_centre,social_facility,hypermarket,international_supermarket,chemist,organic,marketplace,hotel,museum,hostel,guest_house,viewpoint,gallery,playground,discount_gym,gym,yoga,outdoor_fitness_station,childcare,university}',NULL),
	 ('pois_more_entrances',NULL,'{bus_stop,tram_stop,subway_entrance,rail_station,community_sports_center,waterpark,park,forest,heath_scrub,lake,river}',NULL),
	 ('excluded_class_id_walking',NULL,'{0,101,102,103,104,105,106,107,501,502,503,504,701,801}',NULL),
	 ('categories_no_foot',NULL,'{use_sidepath,no}',NULL),
	 ('excluded_class_id_cycling',NULL,'{0,101,102,103,104,105,106,107,501,502,503,504,701,801}',NULL),
	 ('categories_no_bicycle',NULL,'{use_sidepath,no}',NULL),
	 ('categories_sidewalk_no_foot',NULL,'{separate}',NULL),
	 ('max_length_links','300',NULL,NULL),
	 ('custom_landuse_no_residents',NULL,'{AX_TagebauGrubeSteinbruch,AX_SportFreizeitUndErholungsflaeche,AX_FlaecheBesondererFunktionalerPraegung,AX_BauwerkOderAnlageFuerSportFreizeitUndErholung,AX_Halde,AX_Friedhof,AX_IndustrieUndGewerbeflaeche,AX_Landwirtschaft,AX_Wald,AX_Gehoelz,AX_Heide,AX_Moor,AX_Insel,AX_Sumpf,AX_UnlandVegetationsloseFlaeche,AX_Vegetationsmerkmal,AX_Bahnverkehr,AX_Platz,AX_Strassenverkehr,AX_Flugverkehr,AX_Fließgewaesser,AX_Hafenbecken,AX_StehendesGewaesser}',NULL);
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('custom_landuse_with_residents_name',NULL,'{%seniorenheim%}',NULL),
	 ('custom_landuse_additional_no_residents',NULL,'{Water,"Permanent crops (vineyards, fruit trees, olive groves)","Railways and associated land","Herbaceous vegetation associations (natural grassland, moors...)",Forests,"Sports and leisure facilities","Other roads and associated land","Green urban areas","Arable land (annual crops)","Fast transit roads and associated land","Industrial, commercial, public, military and private units","Mineral extraction and dump sites",Pastures}',NULL),
	 ('osm_landuse_no_residents',NULL,'{farmyard,construction,farmland,quarry,industrial,retail,commercial,forest,military,cemetery,landfill,allotments,"recreation ground",railway,parking,grass,grassland,green,garages}',NULL),
	 ('aois_no_residents',NULL,'{forest,park,lake,river,forest,park,swimming_lake}',NULL),
	 ('building_types_potentially_residential',NULL,'{yes}',NULL),
	 ('building_types_residential',NULL,'{apartments,bungalow,detached,dormitory,residential,house,terrace,home,semidetached_house}',NULL),
	 ('tourism_no_residents',NULL,'{zoo}',NULL),
	 ('amenity_no_residents',NULL,'{hospital,university,community_centre,school,kindergarten,recreation_ground,wood}',NULL),
	 ('default_building_levels','3',NULL,NULL),
	 ('minimum_building_size_residential','30',NULL,NULL);
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('census_minimum_number_new_buildings','1',NULL,NULL),
	 ('average_gross_living_area','50',NULL,NULL),
	 ('average_building_levels','4',NULL,NULL),
	 ('average_roof_levels','1',NULL,NULL),
	 ('average_height_per_level','3.5',NULL,NULL),
	 ('wheelchair',NULL,NULL,'{"surface_no": ["ground", "grass", "sand", "dirt", "unhewn_cobblestone", "unpaved"], "smoothness_no": ["very_bad", "horrible", "very_horrible", "impassable"], "surface_limited": ["gravel"], "smoothness_limited": ["bad"], "highway_onstreet_yes": ["living_street"], "highway_onstreet_limited": ["residential", "service"]}'),
	 ('lit',NULL,NULL,'{"highway_no": ["track"], "surface_no": ["ground", "gravel", "unpaved", "grass"], "highway_yes": ["living_street", "residential", "secondary", "tertiary"]}'),
	 ('walking_speed_elderly','0.83333',NULL,NULL),
	 ('cycling_surface',NULL,NULL,'{"mud": "0.2", "sand": "0.2", "sett": "0.15", "grass": "0.2", "gravel": "0.2", "unpaved": "0.1", "compacted": "0.1", "cobblestone": "0.15", "fine_gravel": "0.1", "pebblestone": "0.15", "paving_stones": "0.1", "unhewn-cobblestone": "0.15"}'),
	 ('cycling_smoothness',NULL,NULL,'{"bad": "0.05", "horrible": "0.3", "very_bad": "0.1", "intermediate": "0", "very_horrible": "0.35"}');
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('cycling_crossings_delay',NULL,NULL,'{"delay_1": 15, "delay_2": 30}'),
	 ('compute_slope_impedance','no',NULL,NULL),
	 ('categories',NULL,'{was,wac,cys,cyc,whs,whc}',NULL),
	 ('bridge_tunnel',NULL,NULL,'{"bridge": ["yes", "viaduct"], "tunnel": ["yes", "covered"]}'),
	 ('class_cyclepath',NULL,NULL,'{"segregated_yes": ["cycleway"]}'),
	 ('class_obstacle',NULL,NULL,'{"light": ["stop", "street_lamp", "traffic_signal"], "strong": ["steps"], "moderate": ["limited", "no"]}'),
	 ('walking_type_road',NULL,NULL,'{"path": "0", "track": "0.1", "trunk": "1", "bridge": "0.3", "tunnel": "0.3", "footway": "0.1", "primary": "0.8", "service": "0.05", "corridor": "0", "motorway": "1", "tertiary": "0.2", "secondary": "0.6", "pedestrain": "0", "residential": "0.2", "unclassified": "0.2", "living streets": "0"}'),
	 ('walking_peak_hour','0.2',NULL,NULL),
	 ('walking_cyclepath',NULL,NULL,'{"segregated_no": "0", "segregated_yes": "0.5"}'),
	 ('walking_sidewalk',NULL,NULL,'{"ideal": "0", "acceptable": "0.3", "comfortable": "0", "uncomfortable": "0.5"}');
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('walking_obstacle',NULL,NULL,'{"light": "0.1", "strong": "0.3", "moderate": "0.2"}'),
	 ('walking_surface',NULL,NULL,'{"mud": "0.1", "sand": "0.1", "sett": "0.05", "grass": "0.1", "gravel": "0.1", "unpaved": "0", "compacted": "0", "cobblestone": "0.05", "fine_gravel": "0", "pebblestone": "0.05", "paving_stones": "0", "unhewn-cobblestone": "0.05"}'),
	 ('walking_smoothness',NULL,NULL,'{"bad": "0", "horrible": "0.1", "very_bad": "0", "intermediate": "0", "very_horrible": "0.15"}'),
	 ('walking_extra',NULL,NULL,'{"p": "-0.2", "bench": "-0.1", "fountain": "-0.2", "street_lamp": "-0.2", "waste_basket": "-0.1", "bicycle_parking": "0"}'),
	 ('cycling_type_road',NULL,NULL,'{"path": "0.1", "track": "0", "trunk": "1", "bridge": "0.4", "tunnel": "0.4", "footway": "0.2", "primary": "0.3", "service": "0.05", "corridor": "1", "motorway": "1", "tertiary": "0.1", "secondary": "0.2", "pedestrain": "0.5", "residential": "0.1", "unclassified": "0.1", "living streets": "0"}'),
	 ('cycling_peak_hour','0.1',NULL,NULL),
	 ('cycling_cyclepath',NULL,NULL,'{"segregated_no": "0.1", "segregated_yes": "0"}'),
	 ('cycling_sidewalk',NULL,NULL,'{"ideal": "0.1", "acceptable": "0.4", "comfortable": "0.2", "uncomfortable": "0.6"}'),
	 ('cycling_obstacle',NULL,NULL,'{"light": "0.1", "strong": "0.7", "moderate": "0.3"}'),
	 ('cycling_extra',NULL,NULL,'{"p": "-0.1", "bench": "0", "fountain": "-0.2", "street_lamp": "-0.2", "waste_basket": "0", "bicycle_parking": "-0.2"}');
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('wheelchair_type_road',NULL,NULL,'{"path": "0", "track": "0.1", "trunk": "1", "bridge": "0.4", "tunnel": "0.5", "footway": "0", "primary": "0.8", "service": "0.05", "corridor": "0", "motorway": "1", "tertiary": "0.3", "secondary": "0.7", "pedestrain": "0", "residential": "0.3", "unclassified": "0.3", "living streets": "0"}'),
	 ('wheelchair_peak_hour','0.3',NULL,NULL),
	 ('wheelchair_cyclepath',NULL,NULL,'{"segregated_no": "0", "segregated_yes": "0.3"}'),
	 ('wheelchair_sidewalk',NULL,NULL,'{"ideal": "0", "acceptable": "0.5", "comfortable": "0.2", "uncomfortable": "0.7"}'),
	 ('wheelchair_obstacle',NULL,NULL,'{"light": "0.2", "strong": "0.9", "moderate": "0.6"}'),
	 ('wheelchair_surface',NULL,NULL,'{"mud": "0.3", "sand": "0.3", "sett": "0.15", "grass": "0.3", "gravel": "0.3", "unpaved": "0.1", "compacted": "0.1", "cobblestone": "0.15", "fine_gravel": "0.1", "pebblestone": "0.15", "paving_stones": "0.1", "unhewn-cobblestone": "0.15"}'),
	 ('wheelchair_smoothness',NULL,NULL,'{"bad": "0.15", "horrible": "0.5", "very_bad": "0.3", "intermediate": "0.05", "very_horrible": "0.75"}'),
	 ('wheelchair_extra',NULL,NULL,'{"p": "-0.2", "bench": "-0.1", "fountain": "-0.2", "street_lamp": "-0.2", "waste_basket": "-0.1", "bicycle_parking": "0"}'),
	 ('areas_boundaries',NULL,NULL,'{"heath": {"small": [0]}, "parks": {"small": [2000]}, "forest": {"small": [2000]}}'),
	 ('duplicated_lookup_radius','100',NULL,NULL);
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('tag_new_radius','130',NULL,NULL),
	 ('duplicated_kindergarten_lookup_radius','50',NULL,NULL),
	 ('duplicated_primary_school_lookup_radius','40',NULL,NULL),
	 ('duplicated_secondary_school_lookup_radius','40',NULL,NULL),
	 ('one_meter_degree','0.000009',NULL,NULL),
	 ('pois_search_conditions',NULL,NULL,'{"bank": {"sparkasse": ["kreissparkasse", "sparkasse", "stadtsparkasse"], "raiffeisenbank": ["raiffeisenbank", "vr bank", "vr-bank", "volksbank", "volks", "Münchner"], "hypovereinsbank": ["hypo vereinsbank", "hypovereinsbank"]}, "chemist": {"dm": [], "rossmann": []}, "nursery": ["krippe", "kinderkrippe", "kita"], "fast_food": {"mcdonalds": ["mcdonald"]}, "restaurant": {"vapiano": ["vapiano"]}, "health_food": {"vitalia": [], "reformhaus": []}, "hypermarket": {"hit": [], "real": [], "v-markt": [], "kaufland": [], "marktkauf": []}, "supermarket": {"rewe": ["rewe", "rewe city"], "edeka": ["e center", "edeka"]}, "discount_gym": {"fitx": [], "mcfit": [], "fitstar": ["fit-star", "fit star"], "cleverfit": ["clever fit", "cleverfit"], "jumpersfitness": ["jumpers fitness"]}, "discount_supermarket": {"aldi": [], "lidl": [], "netto": [], "norma": [], "penny": []}, "no_end_consumer_store": {"metro": [], "hamberger": []}, "community_sport_centre": ["bezirkssportanlage"], "operators_bicycle_rental": ["münchner verkehrs gesellschaft", "münchner verkehrsgesellschaft", "mvg", "Clear Channel", "clear channel"]}'),
	 ('amenity_config',NULL,NULL,'{"sport": {"discard": ["table_tennis"]}, "leisure": {"add": ["sports_hall", "fitness_center", "sport_center", "track, pitch"], "discard": ["fitness_station"]}, "kindergarten": ["kindergarten"], "primary_school": {"add": ["%grund-%", "%grund %", "%grundsch%"], "discard": ["%grund-schule%"]}, "secondary_school": {"add": ["%haupt-%", "%haupt %", "%hauptsch%", "%mittel-%", "%mittel %", "%mittelsch%", "%real-%", "real %", "%realsch%", "%förder-%", "%förder %", "%fördersch%", "%gesamt-%", "%gesamt %", "%gesamtsch%", "%-gymnasium%", "%gymnasium-%", "% gymnasium%", "%gymnasium %", "%fachobersch%"], "discard": ["%haupt-schule%", "%mittel-schule%", "%real-schule%", "%förder-schule%", "%gesamt-schule%"]}}'),
	 ('walkability',NULL,NULL,'{"comfort": {"slope": 2, "toilets": 1, "fountains": 1, "street_furniture": 2}, "security": {"illumination": 1}, "environment": {"pois": 1, "landuse": 1, "population": 1}, "green_index": {"water": 1, "vegetation": 1}, "sidewalk_quality": {"sidewalk_width": 1, "pavement_quality": 1, "freedom_of_barriers": 1, "sidewalk_availability": 1}, "impacts_road_traffic": {"lanes": 1, "noise": 1, "one_way": 1, "parking": 1, "accidents": 1, "speed_limits": 2}}'),
	 ('amenity',NULL,'{bar,biergarten,cafe,pub,fast_food,ice_cream,restaurant,theatre,cinema,library,night_club,hairdresser,atm,bank,dentist,doctors,pharmacy,fuel,museum,gallery,marketplace}',NULL),
	 ('shop',NULL,'{bakery,butcher,clothes,convenience,general,fashion,florist,greengrocer,kiosk,mall,shoes,sports,supermarket,health_food,discount_supermarket,hypermarket,international_supermarket,chemist,organic}',NULL);
INSERT INTO augsburg.variable_container (identifier,variable_simple,variable_array,variable_object) VALUES
	 ('shop_osm',NULL,'{bakery,butcher,clothes,convenience,general,fashion,florist,greengrocer,kiosk,mall,shoes,sports,supermarket,health_food,chemist}',NULL),
	 ('data_recency','2022-12-29',NULL,NULL);
 