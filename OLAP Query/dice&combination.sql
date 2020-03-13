
-- Dice
set search_path = CRIME_DATA_MART;

-- Vancouver, crime cateory: larceny and burglary, in December
select is_nighttime, neighbourhood, address, holiday_name, crime_category, crime_type, reported_time, crime_severity from
crimefact as CF,
location as L,
date as D,
crime as C
where CF.location_key = L.location_key and
CF.reported_date_key = D.date_key and
CF.crime_key = C.crime_key and
L.city = 'Vancouver' and
C.crime_category in ('larceny', 'burglary') and
extract(month from D.crime_date) = 12 and
L.longitude != 0


-- Denver, crime type: robbery-street and public-order-crimes-other, in Jan
select is_nighttime, neighbourhood, address, holiday_name, crime_category, crime_type, reported_time, crime_severity from
crimefact as CF,
location as L,
date as D,
crime as C
where CF.location_key = L.location_key and
CF.reported_date_key = D.date_key and
CF.crime_key = C.crime_key and
L.city = 'Denver' and
C.crime_type in ('robbery-street', 'public-order-crimes-other') and
extract(month from D.crime_date) = 1 and
L.longitude != 0

-- Vancouver, crime type: traffic-accident-fatal and traffic-accident-injury, in Feb
select is_nighttime, neighbourhood, address, holiday_name, crime_category, crime_type, reported_time, crime_severity from
crimefact as CF,
location as L,
date as D,
crime as C
where CF.location_key = L.location_key and
CF.reported_date_key = D.date_key and
CF.crime_key = C.crime_key and
L.city = 'Vancouver' and
C.crime_type in ('traffic-accident-fatal', 'traffic-accident-injury') and
extract(month from D.crime_date) = 2


-- Combination

-- Vancouver, traffic accident during NHL
select * from(
  select L.address, count(*) as num_accident from
  crimefact as CF,
  location as L,
  date as D,
  crime as C,
  event as E
  where CF.location_key = L.location_key and
  CF.reported_date_key = D.date_key and
  CF.crime_key = C.crime_key and
  CF.event_key = E.event_key and
  L.city = 'Vancouver' and
  C.crime_type in ('traffic-accident-fatal', 'traffic-accident-injury') and
  E.event_name = 'NHL'
  group by L.address
  order by count(*) desc
) as q where q.num_accident > 2

-- Vancouver, total crime
select crime_category, (extract(month from D.crime_date)) as month, count(*) as num_crime from
crimefact as CF,
date as D,
crime as C,
location as L
where
CF.reported_date_key = D.date_key and
CF.crime_key = C.crime_key and
CF.location_key = L.location_key and
L.city = 'Vancouver'
group by month, C.crime_category
order by month asc

-- Vancouver versus Denver, count on different crime categories, on New Year's Day and Chritsmas
select crime_category, count(*) as crime_count, city from
crimefact as CF,
date as D,
location as L,
crime as C
where
CF.reported_date_key = D.date_key and
CF.location_key = L.location_key and
CF.crime_key = C.crime_key and
D.holiday_name in ('New Year''s Day', 'Christmas Day')
group by C.crime_category, L.city
order by city asc, crime_count desc
