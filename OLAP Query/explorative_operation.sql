--iceberg queries
SELECT l.neighbourhood, l.address, count(l.location_key)
FROM crime_data_mart.crimefact as f,
     crime_data_mart.location as l,
     (SELECT _c.*
      FROM crime_data_mart.crime as _c
      WHERE _c.crime_category = 'burglary' or
              _c.crime_category = 'auto-theft' or
              _c.crime_category = 'larceny' or
              _c.crime_category = 'theft-from-motor-vehicle') as c
WHERE l.city='Denver' and
        f.location_key = l.location_key and
        f.crime_key = c.crime_key
GROUP BY l.neighbourhood, l.address
ORDER BY count(l.location_key) desc
limit 10;


SELECT d.holiday_name, count(d.holiday_name)
FROM crime_data_mart.crimefact as f,
     crime_data_mart.date as d
WHERE f.reported_date_key = d.date_key and d.holiday_name != 'NOT APPLICABLE'
GROUP BY d.holiday_name, d.holiday_name
ORDER BY count(d.holiday_name) desc
LIMIT 10;

