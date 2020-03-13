-- drll down for 2016 vancourver
select l.city, count(*) 
from crime_data_mart.crimefact as cf inner join
	 crime_data_mart.location as l
	 on cf.location_key = l.location_key inner join
	 crime_data_mart.date as d
	 on d.date_key = cf.reported_date_key
where extract(year from d.crime_date)='2016' and l.city ='Vancouver'
group by l.city

--drill down for 2016/4 vancourver
select l.city, count(*)
from crime_data_mart.crimefact as cf inner join
	crime_data_mart.location as l on  cf.location_key = l.location_key inner join
	crime_data_mart.date as d on d.date_key = cf.reported_date_key
where extract(year from d.crime_date)='2016' and extract(month from d.crime_date)='4' and l.city ='Vancouver'
group by l.city

--drill down to riley park in Vancourver on 2016/4 with crime_cal of burglary
select l.city, l.neighbourhood,crime.crime_type, count(*)
from crime_data_mart.crimefact as cf inner join 
	 crime_data_mart.location as l on cf.location_key = l.location_key inner join 
	 crime_data_mart.date as d on d.date_key = cf.reported_date_key inner join
	 crime_data_mart.crime as crime on cf.crime_key = crime.crime_key
where  l.city ='Vancouver' and extract(year from d.crime_date)='2016' and extract(month from d.crime_date)='4' and l.neighbourhood = 'Riley Park' and crime.crime_category = 'burglary'
group by l.city,l.neighbourhood,crime.crime_type

--drill down to 2016-4-20in Vancourver on 2016/4/20 with crime_cal of burglary
select l.city, d.crime_date,crime.crime_type, count(*)
from crime_data_mart.crimefact as cf inner join 
	 crime_data_mart.location as l on cf.location_key = l.location_key inner join
	 crime_data_mart.date as d on cf.reported_date_key = d.date_key inner join 
	 crime_data_mart.crime as crime on cf.crime_key = crime.crime_key
	 
where l.city ='Vancouver' and d.crime_date ='2016-4-20' and crime.crime_category = 'burglary'
group by l.city, d.crime_date, crime.crime_type

--slice , the crime per city during March 2016.
select l.city,  d.crime_date, crime.crime_type
from crime_data_mart.crimefact as cf inner join 
	crime_data_mart.location as l on cf.location_key = l.location_key inner join
	crime_data_mart.crime as crime on cf.crime_key = crime.crime_key inner join
	crime_data_mart.date as d on cf.reported_date_key = d.date_key
	
	 
where extract(year from d.crime_date)='2016' and extract(month from d.crime_date)='3'
group by l.city,  d.crime_date, crime.crime_type

--slice the criem catelogy of burglary in per city all the time
select l.city,  d.crime_date, crime.crime_category,count(*)
from crime_data_mart.crimefact as cf inner join 
	crime_data_mart.location as l on cf.location_key = l.location_key inner join
	crime_data_mart.crime as crime on cf.crime_key = crime.crime_key inner join
	crime_data_mart.date as d on cf.reported_date_key = d.date_key
	
	 
where crime.crime_category = 'burglary'
group by  d.crime_date,l.city,  crime.crime_category
order by d.crime_date ,l.city

-- roll up number of crime is in nighttime crime_type and neibourhood as group and individual
SELECT crime.crime_type , l.neighbourhood ,GROUPING(crime.crime_type , l.neighbourhood ),sum (cf.is_nighttime::int)
from crime_data_mart.crimefact as cf inner join 
crime_data_mart.location as l on cf.location_key = l.location_key inner join
crime_data_mart.crime as crime on cf.crime_key = crime.crime_key 
GROUP BY ROLLUP(  crime.crime_type,l.neighbourhood )
ORDER BY
l.neighbourhood,crime.crime_type

-- roll up number of crime is fatal for crime_type and event type as group and individual
SELECT crime.crime_type , e.event_type ,GROUPING(crime.crime_type , e.event_type ),sum (cf.is_fatal::int)
from crime_data_mart.crimefact as cf inner join 
crime_data_mart.event as e on cf.event_key = e.event_key inner join
crime_data_mart.crime as crime on cf.crime_key = crime.crime_key 
GROUP BY ROLLUP(  crime.crime_type,e.event_type )
ORDER BY
e.event_type,crime.crime_type
