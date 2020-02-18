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
                                                             'REPORTED_DATE'], nrows=100) #TODO

        df['DATE_F'] = pd.DatetimeIndex(df['FIRST_OCCURRENCE_DATE']).date
        df['DATE_L'] = pd.DatetimeIndex(df['LAST_OCCURRENCE_DATE']).date
        df['DATE_R'] = pd.DatetimeIndex(df['REPORTED_DATE']).date
        df['TIME_F'] = pd.DatetimeIndex(df['FIRST_OCCURRENCE_DATE']).time
        df['TIME_L'] = pd.DatetimeIndex(df['LAST_OCCURRENCE_DATE']).time
        df['TIME_R'] = pd.DatetimeIndex(df['REPORTED_DATE']).time

        # 2723000 is the average population from 2015 to 2020
        crime_rate = (len(df) / 6) * (10000 / 2723000)
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
    city = 'Denver'
    return {'longitude': lon, 'latitude': lat, 'city': city, 'neighbourhood': neighbourhood, 'address': address,
            'crime_rate': crime_rate}, 'location_key'


def crime_data(c_category, c_type, first_occurrence_date, last_occurrence_date, report_date):
    """
    prepare the location data to be inserted into crime dimension
    :param c_category: (str) crime category
    :param c_type: (str) crime type
    :param first_occurrence_date: (datetime) first occurrence date
    :param last_occurrence_date: (datetime) last occurrence date
    :param report_date: (datetime) case reported date
    :return: (dict, str) a dictionary containing all info that is inserting into crime dimension, crime_key dict key
    """
    is_violent = read_json('./data/denver_related.json')['violent-crime']
    severity = 'non-vio'
    if (c_category in is_violent) or (c_type in is_violent):
        severity = 'vio'

    first_time = str(first_occurrence_date.hour) + ':' + str(first_occurrence_date.minute) + ':' + \
                 str(first_occurrence_date.second)
    if last_occurrence_date is not None:
        last_time = str(first_occurrence_date.hour) + ':' + str(first_occurrence_date.minute) + ':' + \
                    str(first_occurrence_date.second)
    else :
        last_time = first_time
    return {'crime_category': c_category, 'crime_type': c_type, 'first_occurrence_time': first_time,
            'last_occurrence_time': last_time, 'report_time': report_date, 'crime_severity': severity}, 'crime_key'


def weather_data(date_f, time_f):
    """
    prepare the location data to be inserted into weather dimension
    :param date_f: (datetime) the first occurrence date for denver data
    :param time_f: (datetime) the first occurrence time for denver data
    :return: (dict, str) a dictionary containing all info that is inserting into weather dimension, weather_key dict key
    """
    weather_df = pd.read_csv('./data/Latest Denver & Vancouver weather data.csv', parse_dates=['dt_iso'])
    weather_df = weather_df[weather_df['city_name'] == 'Denver']
    weather_df['DATE'] = pd.DatetimeIndex(weather_df['dt_iso']).date
    crime_date_weather = weather_df[weather_df['DATE'] == date_f]
    crime_time_weather = crime_date_weather[pd.DatetimeIndex(crime_date_weather['dt_iso']).hour == time_f.hour]

    temp = crime_time_weather['temp']
    w_desc = crime_time_weather['weather_description']
    humidity = crime_time_weather['humidity']
    return {'temperature': temp, 'weather_description': w_desc, 'humidity': humidity, 'city': 'Denver'}, 'weather_key'


def event_data():
    # TODO
    return


def fact_data():

    return
