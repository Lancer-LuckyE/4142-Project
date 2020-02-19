import pandas as pd
import holidays
import json
import pyproj


ca_holidays = holidays.CA()


def read_json(path):
    with open(path) as f:
        data = json.load(f)
    return data


def read_files(path):
    """
    read csv file into dataframe
    :param path:(str) csv file location.
    :return: (dataframe, str)the dataframe of the csv file, country name either be US or CA
    :raise FileNotFoundError if there's no denver or van in file name.
    """
    if 'van' in path:
        path_ = 'Data Staging/data/van_crime.csv'
        df = pd.read_csv(path, dtype={'HOUR': str, 'YEAR': int, 'MONTH': str, 'DAY': str, 'MINUTE': str}, nrows=100)
        # concatenate month, day, year, hour, minute and convert to datetime
        df = df.loc[df['YEAR'] >= 2015]
        df['YEAR'] = df['YEAR'].apply(str)
        df['DATETIME'] = df['MONTH'] + '/' + df['DAY'] + '/' + df['YEAR'] + " " + df['HOUR'] + ':' + df['MINUTE'] + ':00'
        df['DATETIME'] = df['DATETIME'].apply(pd.to_datetime)
        df['DATE_R'] = pd.DatetimeIndex(df['DATETIME']).date
        df['TIME_R'] = pd.DatetimeIndex(df['DATETIME']).time


        # calculate crime rate
        # 651416 is the average population from 2004 to 2017
        crime_rate = (len(df) / len(df['YEAR'].unique())) * (10000 / 651416)
        df['CRIME_RATE'] = crime_rate

        return df
    else:
        raise FileNotFoundError


def date_data(crime_date):
    """
    Use date to find relative information
    :param crime_date:(datetime) data read from the csv dataframe
    :return:(dict, str) a dictionary containing all info that is inserting into date dimension, date_key dict key
    """
    day_of_week = crime_date.day_name()
    week_of_year = crime_date.weekofyear
    quarter = crime_date.quarter
    if day_of_week == 'Saturday' or day_of_week == 'Sunday':
        weekend = True
    else:
        weekend = False
    if ca_holidays.get(crime_date) is not None:
        holiday = True
        holiday_name = ca_holidays.get(crime_date)
    else:
        holiday = False
        holiday_name = None

    return {'crime_date': crime_date, 'day_of_the_week': day_of_week, 'week_of_the_year': week_of_year,
            'quarter': quarter, 'weekend': weekend, 'holiday': holiday, 'holiday_name': holiday_name}, 'date_key'


def location_data(x, y, neighbourhood, address, crime_rate):
    """
    prepare the location data to insert into location dimension
    :param x: (float)
    :param y: (float)
    :param neighbourhood: (str) neighbourhood id from the dataframe
    :param address: (str) the address from the dataframe
    :param crime_rate: (float) the average crime rate of the city
    :return: (dict, str) a dictionary containing all info that is inserting into location dimension, location_key dict key
    """

    inproj = pyproj.Proj(proj='utm', zone=10, ellps='WGS84')
    outproj = pyproj.Proj('epsg:4326')
    lon, lat = pyproj.transform(inproj, outproj, x, y)

    city = 'Vancouver'
    return {'longitude': lon, 'latitude': lat, 'city': city, 'neighbourhood': neighbourhood, 'address': address,
            'crime_rate': crime_rate}, 'location_key'


def crime_data(c_type, time_r):
    """
    prepare the location data to be inserted into crime dimension
    :param c_type: (str) crime type
    :param time_r: (datetime.time) case reported date
    :return: (dict, str) a dictionary containing all info that is inserting into crime dimension, crime_key dict key
    """
    van_related = read_json('../data/van_related.json')
    is_violent = van_related['violent-crime']
    c_type_mapping = van_related['type-mapping']
    c_category = c_type_mapping[c_type][0]
    c_type = c_type_mapping[c_type][1]

    severity = 'non-vio'
    if (c_category in is_violent) or (c_type in is_violent):
        severity = 'vio'
    return {'crime_category': c_category, 'crime_type': c_type, 'report_time': time_r, 'crime_severity': severity}, 'crime_key'


def weather_data(date_r, time_r, weather_df):
    """
    prepare the location data to be inserted into weather dimension
    :param date_r: (datetime.date) the report occurrence date for denver data
    :param time_r: (datetime.time) the report time for denver data
    :param weather_df: (dataframe) the weather dataframe that is used to be matched
    :return: (dict, str) a dictionary containing all info that is inserting into weather dimension, weather_key dict key
    """
    weather_df = weather_df[weather_df['city_name'] == 'Vancouver']
    crime_date_weather = weather_df[weather_df['date'] == date_r]
    crime_time_weather = crime_date_weather[pd.DatetimeIndex(crime_date_weather['datetime']).hour == time_r.hour]
    crime_time_weather = crime_time_weather.iloc[0]
    temp = crime_time_weather['temperature']
    w_desc = crime_time_weather['weather_description']
    humidity = crime_time_weather['humidity']
    main_weather = crime_time_weather['weather_main']
    return {'main_weather': main_weather, 'temperature': temp, 'weather_description': w_desc, 'humidity': humidity,
            'city': 'Denver'}, 'weather_key'


def event_data(date_r, event_df):
    """
    prepare the location data to be inserted into event dimension
    :param date_r: (datetime.date) the first occurrence date
    :param event_df: (dataframe) the event data used to be matched
    :return: (dict, str) a dictionary containing all info that is inserting into event dimension, event_key dict key
    """
    event_df = event_df[event_df['city'] == 'Vancouver']
    event = event_df[event_df['event_end_time'] == pd.Timestamp(date_r)]
    if not event.empty:
        event = event.iloc[0]
        return {'event_name': event['event_name'], 'event_type': event['event_type'], 'event_location': event['event_location'],
                'event_location_size': event['event_location_size']}, "event_key"
    else:
        return None, "event_key"


def fact_data(crime_key, location_key, weather_key, date_f_key, date_l_key, date_r_key, event_key, time_r,
              c_type):
    """
    Assume night time flag is calculated basing on the first occurrence time.
    prepare the location data to be inserted into fact dimension
    :param crime_key: (int)
    :param location_key: (int)
    :param weather_key: (int)
    :param date_f_key: (int)
    :param date_l_key: (int)
    :param date_r_key: (int)
    :param event_key: (int)
    :param is_traffic: (bool)
    :param time_r: (datetime.time) reported time
    :param c_type: (str) crime type
    :return: (dict, str) a dictionary containing all info that is inserting into fact dimension, fact_key dict key
    """
    if (c_type == 'Vehicle Collision or Pedestrian Struck (with Fatality)') or (c_type == 'Vehicle Collision or Pedestrian Struck (with Injury)'):
        is_traffic = True
    else:
        is_traffic = False

    van_related = read_json('../data/van_related.json')
    c_type_mapping = van_related['type-mapping']
    c_category = c_type_mapping[c_type][0]
    c_type = c_type_mapping[c_type][1]
    is_fatal = van_related['fatal-crime']
    if (c_category in is_fatal) or (c_type in is_fatal):
        is_fatal = True
    else:
        is_fatal = False

    if (time_r.hour >= 21) or (time_r.hour <= 5):
        is_nighttime = True
    else:
        is_nighttime = False

    return {'crime_key': crime_key, 'location_key': location_key, 'weather_key': weather_key,
            'first_occurrence_date_key': date_f_key, 'last_occurrence_date_key': date_l_key, 'report_date_key': date_r_key,
            'event_key': event_key, 'is_traffic': is_traffic, 'is_nighttime': is_nighttime, 'is_fatal': is_fatal}, 'fact_key'
