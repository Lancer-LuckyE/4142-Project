SET search_path = CRIME_DATA_MART;
DROP SCHEMA IF EXISTS CRIME_DATA_MART CASCADE;
CREATE SCHEMA CRIME_DATA_MART;



CREATE DOMAIN CRIME_DATA_MART.DAY_OF_WEEK AS CHAR CHECK(
  VALUE IN(
    'Monday', 'Tuesday', 'Wednesday', 
    'Thursday', 'Friday', 'Saturday', 
    'Sunday'
  )
);



CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.Date(
  date_key SERIAL NOT NULL, 
  crime_date DATE,
  day_of_the_week DAY_OF_WEEK, 
  week_of_the_year INT, 
  quarter INT, 
  weekend BOOLEAN, 
  holiday BOOLEAN, 
  holiday_name VARCHAR(50), 
  PRIMARY KEY(date_key)
);



CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.Location(
  location_key SERIAL NOT NULL, 
  longitude DOUBLE PRECISION, 
  latitude DOUBLE PRECISION, 
  city VARCHAR(20), 
  neighbourhood VARCHAR(50), 
  address VARCHAR(100), 
  crime_rate DOUBLE PRECISION,
  PRIMARY KEY(location_key)
);



CREATE DOMAIN CRIME_DATA_MART.CRIME_CATEGORY AS CHAR CHECK(
  VALUE IN(
    'aggravated_assault', 'all_other_crimes', 
    'arson', 'auto_theft', 'burglary', 
    'drug_alcohol', 'larceny', 'murder', 
    'other_crimes_against_persons', 
    'public_disorder', 'robbery', 'sexual_assault', 
    'theft_from_motor_vehicle', 'traffic_accident', 
    'white_collar_crime'
  )
);



CREATE DOMAIN CRIME_DATA_MART.CRIME_TYPE AS CHAR CHECK(
  VALUE IN(
    'weapon_unlawful_discharge_of', 
    'theft_other', 
    'theft_items_from_vehicle', 
    'theft_shoplift', 
    'traf_other', 
    'theft_parts_from_vehicle', 
    'criminal_trespassing', 
    'traffic_accident_hit_and_run', 
    'drug_methampetamine_possess', 
    'theft_of_motor_vehicle', 
    'fraud_by_use_of_computer', 
    'traffic_accident', 
    'burglary_business_by_force', 
    'theft_embezzle', 
    'threats_to_injure', 
    'theft_from_bldg', 
    'liquor_possession', 
    'aggravated_assault', 
    'criminal_mischief_mtr_veh', 
    'kidnap_adult_victim', 
    'violation_of_restraining_order', 
    'criminal_mischief_other', 
    'assault_simple', 
    'harassment_stalking_dv', 
    'traf_vehicular_assault', 
    'vehicular_eluding_no_chase', 
    'robbery_street', 
    'public_order_crimes_other', 
    'drug_synth_narcotic_possess', 
    'burglary_residence_by_force', 
    'burglary_business_no_force', 
    'contraband_into_prison', 
    'criminal_mischief_graffiti', 
    'drug_heroin_possess', 
    'drug_poss_paraphernalia', 
    'burglary_residence_no_force', 
    'traf_habitual_offender', 
    'theft_bicycle', 
    'weapon_poss_illegal_dangerous', 
    'disturbing_the_peace', 
    'traffic_accident_dui_duid', 
    'sex_off_fail_to_register', 
    'weapon_by_prev_offender_powpo', 
    'theft_of_services', 
    'sex_aslt_non_rape', 
    'violation_of_court_order', 
    'drug_cocaine_possess', 
    'drug_heroin_sell', 
    'drug_fraud_to_obtain', 
    'assault_police_simple', 
    'assault_dv', 
    'littering', 
    'aggravated_assault_dv', 
    'burglary_vending_machine', 
    'drug_marijuana_possess', 
    'homicide_other', 
    'sex_aslt_rape', 
    'drug_hallucinogen_possess', 
    'police_false_information', 
    'police_resisting_arrest', 
    'theft_unauth_use_of_ftd', 
    'sex_aslt_rape_pot', 
    'police_interference', 
    'accessory_conspiracy_to_crime', 
    'forgery_other', 
    'drug_pcs_other_drug', 
    'menacing_felony_w_weap', 
    'weapon_carrying_prohibited', 
    'indecent_exposure', 
    'robbery_residence', 
    'drug_methampetamine_sell', 
    'drug_cocaine_sell', 
    'animal_cruelty_to', 
    'bomb_threat', 
    'harassment', 
    'theft_fail_return_rent_veh', 
    'arson_other', 
    'public_fighting', 
    'harassment_sexual_in_nature', 
    'burg_auto_theft_resd_w_force', 
    'forgery_counterfeit_of_obj', 
    'fraud_identity_theft', 
    'sex_off_registration_viol', 
    'arson_vehicle', 
    'theft_from_mails', 
    'robbery_car_jacking', 
    'public_peace_other', 
    'kidnap_dv', 
    'curfew', 
    'pawn_broker_viol', 
    'false_imprisonment', 
    'theft_of_rental_property', 
    'weapon_fire_into_occ_bldg', 
    'robbery_business', 
    'weapon_other_viol', 
    'sex_aslt_fondle_adult_victim', 
    'fraud_nsf_closed_account', 
    'forgery_checks', 
    'theft_stln_vehicle_trailer', 
    'drug_marijuana_cultivation', 
    'theft_purse_snatch_no_force', 
    'agg_aslt_police_weapon', 
    'burglary_poss_of_tools', 
    'fraud_by_telephone', 
    'fraud_criminal_impersonation', 
    'obscene_material_possess', 
    'eavesdropping', 
    'drug_marijuana_sell', 
    'harassment_dv', 
    'probation_violation', 
    'property_crimes_other', 
    'sex_aslt_non_rape_pot', 
    'prostitution_engaging_in', 
    'weapon_carrying_concealed', 
    'police_disobey_lawful_order', 
    'forgery_poss_of_forged_inst', 
    'theft_pick_pocket', 
    'fireworks_possession', 
    'arson_business', 
    'escape', 
    'burg_auto_theft_resd_no_force', 
    'arson_residence', 
    'reckless_endangerment', 
    'disarming_a_peace_officer', 
    'sex_aslt_w_object', 
    'wiretapping', 
    'theft_stln_veh_const_eqpt', 
    'robbery_bank', 
    'illegal_dumping', 
    'police_obstruct_investigation', 
    'extortion', 
    'robbery_purse_snatch_w_force', 
    'sex_aslt_w_object_pot', 
    'other_enviornment_animal_viol', 
    'drug_forgery_to_obtain', 
    'obstructing_govt_operation', 
    'impersonation_of_police', 
    'stolen_property_buy_sell_rec', 
    'parole_violation', 
    'weapon_flourishing', 
    'drug_methamphetamine_mfr', 
    'liquor_sell', 
    'burglary_safe', 
    'gambling_gaming_operation', 
    'contraband_possession', 
    'obscene_material_mfr', 
    'burg_auto_theft_busn_w_force', 
    'weapon_fire_into_occ_veh', 
    'drug_synth_narcotic_sell', 
    'intimidation_of_a_witness', 
    'window_peeping', 
    'burg_auto_theft_busn_no_force', 
    'violation_of_custody_order', 
    'vehicular_eluding', 
    'explosive_incendiary_dev_pos', 
    'explosive_incendiary_dev_use', 
    'drug_opium_or_deriv_possess', 
    'drug_hallucinogen_mfr', 
    'prostitution_aiding', 
    'animal_poss_of_dangerous', 
    'traf_vehicular_homicide', 
    'homicide_family', 
    'prostitution_pimping', 
    'police_making_a_false_rpt', 
    'theft_gas_drive_off', 
    'gambling_device', 
    'aslt_agg_police_gun', 
    'drug_hallucinogen_sell', 
    'arson_public_building', 
    'drug_make_sell_other_drug', 
    'homicide_conspiracy', 
    'bribery', 
    'theft_confidence_game', 
    'drug_barbiturate_mfr', 
    'traf_impound_vehicle', 
    'forgery_poss_of_forged_ftd', 
    'forgery_posses_forge_device', 
    'sex_asslt_sodomy_man_strng_arm', 
    'drug_barbiturate_possess', 
    'drug_opium_or_deriv_sell', 
    'weapon_unlawful_sale', 
    'escape_aiding', 
    'weapon_altering_serial_number', 
    'failure_to_appear', 
    'liquor_misrepresent_age_minor', 
    'drug_barbiturate_sell', 
    'loitering', 
    'liquor_other_viol', 
    'theft_from_yards', 
    'theft_of_cable_services', 
    'explosives_posses', 
    'failure_to_report_abuse', 
    'liquor_manufacturing', 
    'money_laundering', 
    'riot_incite', 
    'homicide_negligent', 
    'gambling_betting_wagering', 
    'riot', 
    'altering_vin_number', 
    'homicide_police_by_gun', 
    'break_enter_commercial', 
    'break_enter_residential_other', 
    'homicide', 
    'mischief', 
    'offence_against_a_person', 
    'theft_from_vehicle', 
    'traffic_accident_fatal', 
    'traffic_accident_inhury'
  )
);


CREATE DOMAIN CRIME_DATA_MART.CRIME_SEVERITY AS CHAR CHECK(
  VALUE IN(
    'violent', 'non-violent'
  )
);


CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.Crime(
  crime_key SERIAL NOT NULL, 
  crime_category CRIME_CATEGORY, 
  crime_type CRIME_TYPE, 
  first_occurence_time TIME WITHOUT TIME ZONE, 
  last_occurence_time TIME WITHOUT TIME ZONE, 
  report_time TIME WITHOUT TIME ZONE,
  crime_severity CRIME_SEVERITY,
  PRIMARY KEY(crime_key)
);



CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.Weather(
  weather_key SERIAL NOT NULL, 
  temperature REAL, 
  weather_description VARCHAR(30), 
  humidity REAL, 
  precipitation REAL,
  PRIMARY KEY(weather_key)
);


CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.Event(
  event_key SERIAL NOT NULL, 
  event_name VARCHAR(30),
  event_type VARCHAR(30),
  event_location VARCHAR(50),
  event_location_size INT,
  PRIMARY KEY(event_key)
);




CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.CrimeFact(
  crime_key SERIAL NOT NULL, 
  location_key SERIAL NOT NULL, 
  weather_key SERIAL NOT NULL, 
  report_date_key SERIAL NOT NULL, 
  event_key SERIAL NOT NULL, 
  is_traffic BOOLEAN, 
  is_nighttime BOOLEAN, 
  is_fatal BOOLEAN, 
  PRIMARY KEY(
    crime_key, location_key, 
    weather_key, report_date_key,
    event_key
  ), 
  FOREIGN KEY(crime_key) REFERENCES CRIME_DATA_MART.Crime(crime_key), 
  FOREIGN KEY(location_key) REFERENCES CRIME_DATA_MART.Location(location_key), 
  FOREIGN KEY(weather_key) REFERENCES CRIME_DATA_MART.Weather(weather_key), 
  FOREIGN KEY(first_occurrence_date_key) REFERENCES CRIME_DATA_MART.Date(date_key), 
  FOREIGN KEY(last_occurrence_date_key) REFERENCES CRIME_DATA_MART.Date(date_key), 
  FOREIGN KEY(report_date_key) REFERENCES CRIME_DATA_MART.Date(date_key),
  FOREIGN KEY(event_key) REFERENCES CRIME_DATA_MART.Event(event_key)
);




