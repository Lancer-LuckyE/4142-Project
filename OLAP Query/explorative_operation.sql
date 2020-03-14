--iceberg queries
-- Top 10 locations in Denver with the highest occurrence of thefts (only larceny)
SELECT l.neighbourhood, l.address, count(l.location_key)
FROM crime_data_mart.crimefact as f,
     crime_data_mart.location as l,
     crime_data_mart.crime as c
WHERE l.city = 'Denver'
  and f.location_key = l.location_key
  and f.crime_key = c.crime_key
  and c.crime_category = 'larceny'
GROUP BY l.neighbourhood, l.address
ORDER BY count(l.location_key) desc
limit 10;

-- Top 10 holiday in Denver with the highest occurrence of crime
SELECT d.holiday_name, count(d.holiday_name)
FROM crime_data_mart.crimefact as f,
     crime_data_mart.date as d,
     crime_data_mart.location as l
WHERE f.reported_date_key = d.date_key
  and d.holiday_name != 'NOT APPLICABLE'
  and f.location_key = l.location_key
  and l.city = 'Denver'
GROUP BY d.holiday_name, d.holiday_name
ORDER BY count(d.holiday_name) desc
LIMIT 10;

-- Top 10 crime categories in Denver
SELECT c.crime_category, c.crime_type, count(c.crime_category)
FROM crime_data_mart.crimefact as f,
     crime_data_mart.crime as c,
     crime_data_mart.location as l
WHERE f.location_key = l.location_key
  and l.city = 'Denver'
  and f.crime_key = c.crime_key
GROUP BY c.crime_category, c.crime_type
ORDER BY count(c.crime_category) desc
LIMIT 10;

-- windowing queries
-- show the number of crimes per-month for every neighbourhood in Denver
SELECT distinct l.neighbourhood,
                date_trunc('month', d.crime_date)                                            as month,
                count(
                (f.crime_key, f.location_key, f.weather_key, f.reported_date_key, f.event_key)
                    ) OVER (PARTITION BY l.neighbourhood, date_trunc('month', d.crime_date)) as crimes_permonth
FROM crime_data_mart.crimefact as f,
     crime_data_mart.date as d,
     crime_data_mart.location as l
WHERE f.location_key = l.location_key
  and f.reported_date_key = d.date_key
  and l.city = 'Denver'
ORDER BY month asc;

-- show the average number of crimes per neighbourhood per month
SELECT distinct crimes_permonth.month,
       avg(crimes_permonth.crimes_permonth)
       OVER (PARTITION BY date_trunc('month', crimes_permonth.month)
             ORDER BY date_trunc('month', crimes_permonth.month)
             RANGE BETWEEN INTERVAL '1' MONTH PRECEDING and
             Interval '1' MONTH FOLLOWING)
FROM (
         SELECT distinct l.neighbourhood,
                         date_trunc('month', d.crime_date)                                            as month,
                         count(
                         (f.crime_key, f.location_key, f.weather_key, f.reported_date_key, f.event_key)
                             ) OVER (PARTITION BY l.neighbourhood, date_trunc('month', d.crime_date)) as crimes_permonth
         FROM crime_data_mart.crimefact as f,
              crime_data_mart.date as d,
              crime_data_mart.location as l
         WHERE f.location_key = l.location_key
           and f.reported_date_key = d.date_key
           and l.city = 'Denver'
         ORDER BY month asc
     ) as crimes_permonth
ORDER BY month asc;



-- -- show the total number of crimes per-month in Denver
-- SELECT distinct date_trunc('month', crime_per_day.date) as month,
--                 sum(crime_per_day.count)
--                 OVER (partition by date_trunc('month', crime_per_day.date))
-- FROM (
--          SELECT d.crime_date as date, l.neighbourhood, count(date_part('month', d.crime_date))
--          FROM crime_data_mart.crimefact as f,
--               crime_data_mart.date as d,
--               crime_data_mart.location as l
--          WHERE f.reported_date_key = d.date_key
--            and f.location_key = l.location_key
--            and l.city = 'Denver'
--          GROUP BY d.crime_date, l.neighbourhood
--      ) as crime_per_day
-- ORDER BY month asc;
--
-- -- show the number of crimes per-month for every neighbourhood in Denver
-- SELECT distinct crime_per_day.neighbourhood,
--                 date_trunc('month', crime_per_day.date)                                                  as month,
--                 sum(crime_per_day.count)
--                 OVER (partition by crime_per_day.neighbourhood, date_trunc('month', crime_per_day.date)) as num_of_crimes
-- FROM (
--          SELECT d.crime_date as date, l.neighbourhood, count(date_part('month', d.crime_date))
--          FROM crime_data_mart.crimefact as f,
--               crime_data_mart.date as d,
--               crime_data_mart.location as l
--          WHERE f.reported_date_key = d.date_key
--            and f.location_key = l.location_key
--            and l.city = 'Denver'
--          GROUP BY l.neighbourhood, d.crime_date
--      ) as crime_per_day
-- ORDER BY neighbourhood, month asc;
--
-- -- show the average number of crimes for every neighbourhood in Denver
-- SELECT distinct crime_perneigh_permonth.neighbourhood,
--                 date_part('year', crime_perneigh_permonth.month)                                     as year,
--                 avg(crime_perneigh_permonth.num_of_crimes)
--                 OVER (partition by neighbourhood, date_trunc('year', crime_perneigh_permonth.month)) as avg_num_of_crimes
-- FROM (
--          SELECT distinct crime_per_day.neighbourhood,
--                          date_trunc('month', crime_per_day.date)                                                  as month,
--                          sum(crime_per_day.count)
--                          OVER (partition by crime_per_day.neighbourhood, date_trunc('month', crime_per_day.date)) as num_of_crimes
--          FROM (
--                   SELECT d.crime_date as date, l.neighbourhood, count(date_part('month', d.crime_date))
--                   FROM crime_data_mart.crimefact as f,
--                        crime_data_mart.date as d,
--                        crime_data_mart.location as l
--                   WHERE f.reported_date_key = d.date_key
--                     and f.location_key = l.location_key
--                     and l.city = 'Denver'
--                   GROUP BY l.neighbourhood, d.crime_date
--               ) as crime_per_day
--          ORDER BY neighbourhood, month asc
--      ) as crime_perneigh_permonth
-- ORDER BY neighbourhood, year asc;

-- use of window clause
-- show the number of crimes per-month for every neighbourhood in Denver
SELECT distinct l.neighbourhood,
                date_trunc('month', d.crime_date) as month,
                count((f.crime_key, f.location_key, f.weather_key, f.reported_date_key, f.event_key))
                OVER W                            as num_of_crimes
FROM crime_data_mart.crimefact as f,
     crime_data_mart.location as l,
     crime_data_mart.date as d
WHERE f.location_key = l.location_key
  and f.reported_date_key = d.date_key
  and l.city = 'Denver'
    Window W as (
        PARTITION BY l.neighbourhood, date_trunc('month', d.crime_date)
        ORDER BY date_trunc('month', d.crime_date)
        RANGE BETWEEN INTERVAL '1' MONTH PRECEDING
            ANd INTERVAL '1' MONTH FOLLOWING
        );

-- show the number of crimes every year for every neighbourhood in Denver
SELECT distinct l.neighbourhood,
                date_trunc('year', d.crime_date) as year,
                count((f.crime_key, f.location_key, f.weather_key, f.reported_date_key, f.event_key))
                OVER W                           as num_of_crimes
FROM crime_data_mart.crimefact as f,
     crime_data_mart.location as l,
     crime_data_mart.date as d
WHERE f.location_key = l.location_key
  and f.reported_date_key = d.date_key
  and l.city = 'Denver'
    Window W as (
        PARTITION BY l.neighbourhood, date_trunc('year', d.crime_date)
        ORDER BY date_trunc('year', d.crime_date)
        RANGE BETWEEN INTERVAL '1' YEAR PRECEDING
            ANd INTERVAL '1' YEAR FOLLOWING
        );

-- show the average number of crimes for every neighbourhood in Denver
SELECT distinct crimes_permonth.neighbourhood,
                date_part('year', crimes_permonth.month)  as year,
                avg(crimes_permonth.num_of_crimes) OVER W as avg_crimes
FROM (SELECT distinct l.neighbourhood,
                      date_trunc('month', d.crime_date) as month,
                      count((f.crime_key, f.location_key, f.weather_key, f.reported_date_key, f.event_key))
                      OVER W                            as num_of_crimes
      FROM crime_data_mart.crimefact as f,
           crime_data_mart.location as l,
           crime_data_mart.date as d
      WHERE f.location_key = l.location_key
        and f.reported_date_key = d.date_key
        and l.city = 'Denver'
          Window W as (
              PARTITION BY l.neighbourhood, date_trunc('month', d.crime_date)
              ORDER BY date_trunc('month', d.crime_date)
              RANGE BETWEEN INTERVAL '1' MONTH PRECEDING
                  ANd INTERVAL '1' MONTH FOLLOWING
              )
     ) as crimes_permonth
    WINDOW W as (
        PARTITION BY crimes_permonth.neighbourhood, date_trunc('year', crimes_permonth.month)
        ORDER BY date_trunc('year', crimes_permonth.month)
        RANGE BETWEEN INTERVAL '1' YEAR PRECEDING
            AND INTERVAL '1' YEAR FOLLOWING
        )