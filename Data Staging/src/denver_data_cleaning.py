import pandas as pd
import holidays
import json

us_holidays = holidays.US()


def read_json(path):
    with open(path) as f:
        data = json.load(f)
    return data


def read_files(path):
    """
    read csv file into dataframe
    :param path:(str) csv file location.
    :return: (dataframe)the dataframe of the csv file
    :raise: FileNotFoundError
    """
    if 'denver' in path:
        use_col = ["OFFENSE_TYPE_ID", "OFFENSE_CATEGORY_ID", "FIRST_OCCURRENCE_DATE", "LAST_OCCURRENCE_DATE",
                   "REPORTED_DATE", "INCIDENT_ADDRESS", "GEO_LON", "GEO_LAT", "NEIGHBORHOOD_ID", "IS_CRIME",
                   "IS_TRAFFIC"]
        df = pd.read_csv(path, usecols=use_col, parse_dates=['FIRST_OCCURRENCE_DATE', 'LAST_OCCURRENCE_DATE',
                                                             'REPORTED_DATE'], nrows=100)

        df['DATE_F'] = pd.DatetimeIndex(df['FIRST_OCCURRENCE_DATE']).date
        df['DATE_L'] = pd.DatetimeIndex(df['LAST_OCCURRENCE_DATE']).date
        df['DATE_R'] = pd.DatetimeIndex(df['REPORTED_DATE']).date
        df['TIME_F'] = pd.DatetimeIndex(df['FIRST_OCCURRENCE_DATE']).time
        df['TIME_L'] = pd.DatetimeIndex(df['LAST_OCCURRENCE_DATE']).time
        df['TIME_R'] = pd.DatetimeIndex(df['REPORTED_DATE']).time

        # 2723000 is the average population from 2015 to 2020
        crime_rate = (len(df) / 6) * (10000 / 2723000)
        df['CRIME_RATE'] = crime_rate

        #read weather data
        weather_df = pd.read_csv('../data/selected_weather_data.csv', parse_dates=['datetime'])
        weather_df = weather_df[weather_df['city_name'] == 'Denver']
        weather_df['date'] = pd.DatetimeIndex(weather_df['datetime']).date

        #read event data
        event_df = pd.read_csv('../data/event_data.csv', parse_dates=['event_begin_time', 'event_end_time'])
        event_df = event_df[event_df['city'] == 'Denver']

        return df, weather_df, event_df
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
    if us_holidays.get(crime_date) is not None:
        holiday = True
        holiday_name = us_holidays.get(crime_date)
    else:
        holiday = False
        holiday_name = None

    return {'crime_date': crime_date, 'day_of_the_week': day_of_week, 'week_of_the_year': week_of_year,
            'quarter': quarter, 'weekend': weekend, 'holiday': holiday, 'holiday_name': holiday_name}, 'date_key'


def location_data(lon, lat, neighbourhood, address, crime_rate):
    """
    prepare the location data to be inserted into location dimension
    :param lon: (float) longitude from the dataframe
    :param lat: (float) latitude from the dataframe
    :param neighbourhood: (str) neighbourhood id from the dataframe
    :param address: (str) the address from the dataframe
    :param crime_rate: (float) the average crime rate of the city
    :return: (dict, str) a dictionary containing all info that is inserting into location dimension, location_key dict key
    """
    population = read_json('../data/denver_related.json')['population']
    city = 'Denver'
    population = population[neighbourhood]
    return {'longitude': lon, 'latitude': lat, 'city': city, 'neighbourhood': neighbourhood, 'address': address,
            'population': population, 'crime_rate': crime_rate}, 'location_key'


def crime_data(c_category, c_type, time_f, time_l, time_r):
    """
    prepare the location data to be inserted into crime dimension
    :param c_category: (str) crime category
    :param c_type: (str) crime type
    :param time_f: (datetime.time) first occurrence date
    :param time_l: (datetime.time) last occurrence date
    :param time_r: (datetime.time) case reported date
    :return: (dict, str) a dictionary containing all info that is inserting into crime dimension, crime_key dict key
    """
    is_violent = read_json('../data/denver_related.json')['violent-crime']
    severity = 'non-vio'
    if (c_category in is_violent) or (c_type in is_violent):
        severity = 'vio'

    return {'crime_category': c_category, 'crime_type': c_type, 'first_occurrence_time': time_f,
            'last_occurrence_time': time_l, 'report_time': time_r, 'crime_severity': severity}, 'crime_key'


def weather_data(date_f, time_f, weather_df):
    """
    prepare the location data to be inserted into weather dimension
    :param date_f: (datetime.date) the first occurrence date for denver data
    :param time_f: (datetime.time) the first occurrence time for denver data
    :return: (dict, str) a dictionary containing all info that is inserting into weather dimension, weather_key dict key
    """

    crime_date_weather = weather_df[weather_df['date'] == date_f]
    crime_time_weather = crime_date_weather[pd.DatetimeIndex(crime_date_weather['datetime']).hour == time_f.hour]
    crime_time_weather = crime_time_weather.iloc[0]
    temp = crime_time_weather['temperature']
    w_desc = crime_time_weather['weather_description']
    humidity = crime_time_weather['humidity']
    main_weather = crime_time_weather['weather_main']
    return {'temperature': temp, 'weather_description': w_desc, 'humidity': humidity, 'city': 'Denver'}, 'weather_key'


def event_data(date_f, event_df):
    """
    prepare the location data to be inserted into event dimension
    :param date_f:
    :param time_f:
    :return: (dict, str) a dictionary containing all info that is inserting into event dimension, event_key dict key
    """
    event = event_df[event_df['event_end_time'] == pd.Timestamp(date_f)]

    if not event.empty:
        event = event.iloc[0]
        return {'event_name': event['event_name'], 'event_type': event['event_type'], 'event_location': event['event_location'],
                'event_location_size': event['event_location_size']}, "event_key"
    else:
        return None, "event_key"



def fact_data(crime_key, location_key, weather_key, date_f_key, date_l_key, date_r_key, event_key, is_traffic, time_f
              , c_category, c_type):
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
    :param time_f: (datetime.time)
    :param c_category: (str) crime category
    :param c_type: (str) crime type
    :return: (dict, str) a dictionary containing all info that is inserting into fact dimension, fact_key dict key
    """

    is_fatal = read_json('../data/denver_related.json')['fatal-crime']
    if (c_category in is_fatal) or (c_type in is_fatal):
        is_fatal = True
    else:
        is_fatal = False

    if (time_f.hour >= 21) or (time_f.hour <= 5):
        is_nighttime = True
    else:
        is_nighttime = False

    return {'crime_key': crime_key, 'location_key': location_key, 'weather_key': weather_key,
            'first_occurrence_date_key': date_f_key, 'last_occurrence_date_key': date_l_key, 'report_date_key': date_r_key,
            'event_key': event_key, 'is_traffic': is_traffic, 'is_nighttime': is_nighttime, 'is_fatal': is_fatal}, 'fact_key'