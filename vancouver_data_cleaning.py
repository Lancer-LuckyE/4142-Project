import pandas as pd
from datetime import datetime
import holidays
import math
import json


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
        use_col = ["TYPE", "YEAR", "MONTH", "DAY", "HOUR", "MINUTE", "HUNDRED_BLOCK", "NEIGHBOURHOOD", "Latitude",
                   "Longitude"]
        df = pd.read_csv(path, usecols=use_col, dtype={'HOUR': str, 'YEAR': str, 'MONTH': str, 'DAY': str,
                                                         'MINUTE': str})
        # concatenate month, day, year, hour, minute and convert to datetime
        df['DATETIME'] = df['MONTH'] + '/' + df['DAY'] + '/' + df['YEAR'] + ' ' + df['HOUR'] + ':' + df['MINUTE'] + ':00'
        df['DATETIME'] = df['DATETIME'].apply(pd.to_datetime)
        # calculate crime rate
        # 613576 is the average population from 2001 to 2017
        crime_rate = (len(df) / len(df['YEAR'].unique())) * (10000 / 613576)
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


def location_data(lon, lat, neighbourhood, address, crime_rate):
    """
    prepare the location data to insert into location dimension
    :param lon: (float) longitude from the dataframe
    :param lat: (float) latitude from the dataframe
    :param neighbourhood: (str) neighbourhood id from the dataframe
    :param address: (str) the address from the dataframe
    :param crime_rate: (float) the average crime rate of the city
    :return: (dict, str) a dictionary containing all info that is inserting into location dimension, location_key dict key
    """
    city = 'Vancouver'
    return {'longitude': lon, 'latitude': lat, 'city': city, 'neighbourhood': neighbourhood, 'address': address, 'crime_rate': crime_rate}, 'location_key'


def crime_data():
    # TODO
    return


def weather_data():
    # TODO
    return


def event_data():
    # TODO
    return


def fact_data():
    # TODO
    return
