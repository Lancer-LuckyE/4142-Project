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
    'weapon-unlawful-discharge-of', 
    'theft-other', 
    'theft-items-from-vehicle', 
    'theft-shoplift', 
    'traf-other', 
    'theft-parts-from-vehicle', 
    'criminal-trespassing', 
    'traffic-accident-hit-and-run', 
    'drug-methampetamine-possess', 
    'theft-of-motor-vehicle', 
    'fraud-by-use-of-computer', 
    'traffic-accident', 
    'burglary-business-by-force', 
    'theft-embezzle', 
    'threats-to-injure', 
    'theft-from-bldg', 
    'liquor-possession', 
    'aggravated-assault', 
    'criminal-mischief-mtr-veh', 
    'kidnap-adult-victim', 
    'violation-of-restraining-order', 
    'criminal-mischief-other', 
    'assault-simple', 
    'harassment-stalking-dv', 
    'traf-vehicular-assault', 
    'vehicular-eluding-no-chase', 
    'robbery-street', 
    'public-order-crimes-other', 
    'drug-synth-narcotic-possess', 
    'burglary-residence-by-force', 
    'burglary-business-no-force', 
    'contraband-into-prison', 
    'criminal-mischief-graffiti', 
    'drug-heroin-possess', 
    'drug-poss-paraphernalia', 
    'burglary-residence-no-force', 
    'traf-habitual-offender', 
    'theft-bicycle', 
    'weapon-poss-illegal-dangerous', 
    'disturbing-the-peace', 
    'traffic-accident-dui-duid', 
    'sex-off-fail-to-register', 
    'weapon-by-prev-offender-powpo', 
    'theft-of-services', 
    'sex-aslt-non-rape', 
    'violation-of-court-order', 
    'drug-cocaine-possess', 
    'drug-heroin-sell', 
    'drug-fraud-to-obtain', 
    'assault-police-simple', 
    'assault-dv', 
    'littering', 
    'aggravated-assault-dv', 
    'burglary-vending-machine', 
    'drug-marijuana-possess', 
    'homicide-other', 
    'sex-aslt-rape', 
    'drug-hallucinogen-possess', 
    'police-false-information', 
    'police-resisting-arrest', 
    'theft-unauth-use-of-ftd', 
    'sex-aslt-rape-pot', 
    'police-interference', 
    'accessory-conspiracy-to-crime', 
    'forgery-other', 
    'drug-pcs-other-drug', 
    'menacing-felony-w-weap', 
    'weapon-carrying-prohibited', 
    'indecent-exposure', 
    'robbery-residence', 
    'drug-methampetamine-sell', 
    'drug-cocaine-sell', 
    'animal-cruelty-to', 
    'bomb-threat', 
    'harassment', 
    'theft-fail-return-rent-veh', 
    'arson-other', 
    'public-fighting', 
    'harassment-sexual-in-nature', 
    'burg-auto-theft-resd-w-force', 
    'forgery-counterfeit-of-obj', 
    'fraud-identity-theft', 
    'sex-off-registration-viol', 
    'arson-vehicle', 
    'theft-from-mails', 
    'robbery-car-jacking', 
    'public-peace-other', 
    'kidnap-dv', 
    'curfew', 
    'pawn-broker-viol', 
    'false-imprisonment', 
    'theft-of-rental-property', 
    'weapon-fire-into-occ-bldg', 
    'robbery-business', 
    'weapon-other-viol', 
    'sex-aslt-fondle-adult-victim', 
    'fraud-nsf-closed-account', 
    'forgery-checks', 
    'theft-stln-vehicle-trailer', 
    'drug-marijuana-cultivation', 
    'theft-purse-snatch-no-force', 
    'agg-aslt-police-weapon', 
    'burglary-poss-of-tools', 
    'fraud-by-telephone', 
    'fraud-criminal-impersonation', 
    'obscene-material-possess', 
    'eavesdropping', 
    'drug-marijuana-sell', 
    'harassment-dv', 
    'probation-violation', 
    'property-crimes-other', 
    'sex-aslt-non-rape-pot', 
    'prostitution-engaging-in', 
    'weapon-carrying-concealed', 
    'police-disobey-lawful-order', 
    'forgery-poss-of-forged-inst', 
    'theft-pick-pocket', 
    'fireworks-possession', 
    'arson-business', 
    'escape', 
    'burg-auto-theft-resd-no-force', 
    'arson-residence', 
    'reckless-endangerment', 
    'disarming-a-peace-officer', 
    'sex-aslt-w-object', 
    'wiretapping', 
    'theft-stln-veh-const-eqpt', 
    'robbery-bank', 
    'illegal-dumping', 
    'police-obstruct-investigation', 
    'extortion', 
    'robbery-purse-snatch-w-force', 
    'sex-aslt-w-object-pot', 
    'other-enviornment-animal-viol', 
    'drug-forgery-to-obtain', 
    'obstructing-govt-operation', 
    'impersonation-of-police', 
    'stolen-property-buy-sell-rec', 
    'parole-violation', 
    'weapon-flourishing', 
    'drug-methamphetamine-mfr', 
    'liquor-sell', 
    'burglary-safe', 
    'gambling-gaming-operation', 
    'contraband-possession', 
    'obscene-material-mfr', 
    'burg-auto-theft-busn-w-force', 
    'weapon-fire-into-occ-veh', 
    'drug-synth-narcotic-sell', 
    'intimidation-of-a-witness', 
    'window-peeping', 
    'burg-auto-theft-busn-no-force', 
    'violation-of-custody-order', 
    'vehicular-eluding', 
    'explosive-incendiary-dev-pos', 
    'explosive-incendiary-dev-use', 
    'drug-opium-or-deriv-possess', 
    'drug-hallucinogen-mfr', 
    'prostitution-aiding', 
    'animal-poss-of-dangerous', 
    'traf-vehicular-homicide', 
    'homicide-family', 
    'prostitution-pimping', 
    'police-making-a-false-rpt', 
    'theft-gas-drive-off', 
    'gambling-device', 
    'aslt-agg-police-gun', 
    'drug-hallucinogen-sell', 
    'arson-public-building', 
    'drug-make-sell-other-drug', 
    'homicide-conspiracy', 
    'bribery', 
    'theft-confidence-game', 
    'drug-barbiturate-mfr', 
    'traf-impound-vehicle', 
    'forgery-poss-of-forged-ftd', 
    'forgery-posses-forge-device', 
    'sex-asslt-sodomy-man-strng-arm', 
    'drug-barbiturate-possess', 
    'drug-opium-or-deriv-sell', 
    'weapon-unlawful-sale', 
    'escape-aiding', 
    'weapon-altering-serial-number', 
    'failure-to-appear', 
    'liquor-misrepresent-age-minor', 
    'drug-barbiturate-sell', 
    'loitering', 
    'liquor-other-viol', 
    'theft-from-yards', 
    'theft-of-cable-services', 
    'explosives-posses', 
    'failure-to-report-abuse', 
    'liquor-manufacturing', 
    'money-laundering', 
    'riot-incite', 
    'homicide-negligent', 
    'gambling-betting-wagering', 
    'riot', 
    'altering-vin-number', 
    'homicide-police-by-gun', 
    
    'break-enter-commercial', 
    'break-enter-residential-other', 
    'homicide', 
    'murder', 
    'offence-against-a-person', 
    'theft-from-vehicle', 
    'traffic-accident-fatal', 
    'traffic-accident-inhury'
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
  last_occurrence_time TIME WITHOUT TIME ZONE, 
  reported_time TIME WITHOUT TIME ZONE,
  crime_severity CRIME_SEVERITY,
  PRIMARY KEY(crime_key)
);




CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.Weather(
  weather_key SERIAL NOT NULL, 
  temperature REAL,
  weather_main VARCHAR(30),
  weather_description VARCHAR(30), 
  humidity REAL,
  PRIMARY KEY(weather_key)
);



CREATE TABLE IF NOT EXISTS CRIME_DATA_MART.Event(
  event_key SERIAL NOT NULL, 
  event_name VARCHAR(30),
  event_type VARCHAR(30),
  event_begin_date DATE,
  event_end_date DATE,
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




