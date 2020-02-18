import pandas as pd
from datetime import datetime
import holidays
import math
import json
import pyproj

ca_holidays = holidays.CA()


def read_json(path):
    with open(path) as f:
        data = json.load(f)
    return data


# key: vancouver crime type
# value: [unified category, unified type]
VANCOUVER_CRIME_TYPE_MAPPING = {
    'Break and Enter Commercial': ['burglary', 'break-enter-commercial'],
    'Break and Enter Residential/Other': ['burglary', 'break-enter-residential-other'],
    'Homicide': ['murder', 'murder'],
    'Mischief': ['public-disorder', 'mischief'],
    'Offence Against a Person': ['other-crimes-against-persons', 'offence-against-a-person'],
    'Other Theft': ['larceny', 'theft-other'],
    'Theft from Vehicle': ['theft-from-motor-vehicle', 'theft-from-vehicle'],
    'Theft of Bicycle': ['larceny', 'theft-bicycle'],
    'Theft of Vehicle': ['auto-theft', 'theft-of-motor-vehicle'],
    'Vehicle Collision or Pedestrian Struck (with Fatality)': ['traffic-accident', 'traffic-accident-fatal'],
    'Vehicle Collision or Pedestrian Struck (with Injury)': ['traffic-accident', 'traffic-accident-inhury']
}


def read_files(path):
    """
    read csv file into dataframe
    :param path:(str) csv file location.
    :return: (dataframe, str)the dataframe of the csv file, country name either be US or CA
    :raise FileNotFoundError if there's no denver or van in file name.
    """
    if 'van' in path:
        use_col = ["TYPE", "YEAR", "MONTH", "DAY", "HOUR", "MINUTE", "HUNDRED_BLOCK", "NEIGHBOURHOOD", "X",
                   "Y"]
        df = pd.read_csv(path, usecols=use_col, dtype={'HOUR': str, 'YEAR': str, 'MONTH': str, 'DAY': str,
                                                       'MINUTE': str, 'X': float, 'Y': float}, nrows=10)
        # concatenate month, day, year, hour, minute and convert to datetime
        df['DATE'] = df['MONTH'] + '/' + df['DAY'] + '/' + df['YEAR']
        df['TIME'] = df['HOUR'] + ':' + df['MINUTE'] + ':00'
        df['DATE'] = df['DATE'].apply(pd.to_datetime)
        # calculate crime rate
        # 613576 is the average population from 2001 to 2017
        crime_rate = (len(df) / len(df['YEAR'].unique())) * (10000 / 613576)
        df['CRIME_RATE'] = crime_rate

        # Convert UTM coordinates to longitude and latitude
        inproj = pyproj.Proj(proj='utm', zone=10, ellps='WGS84')
        outproj = pyproj.Proj('epsg:4326')
        longitude_lst, latitude_lst = [], []
        x_lst, y_lst = df['X'].to_list(), df['Y'].to_list()
        for x, y in zip(x_lst, y_lst):
            lo, la = pyproj.transform(inproj, outproj, x, y)
            longitude_lst.append(lo)
            latitude_lst.append(la)
        df['LONGITUDE'], df['LATITUDE'] = longitude_lst, latitude_lst
        df = df.drop(columns=['X', 'Y'])

        # Map original crime type to unified category and type
        original_crime_type_lst = df['TYPE'].to_list()
        unified_crime_category, unified_crime_type = [], []
        for e in original_crime_type_lst:
            c, t = VANCOUVER_CRIME_TYPE_MAPPING[e]
            unified_crime_category.append(c)
            unified_crime_type.append(t)
        df['CRIME_CATEGORY'] = unified_crime_category
        df['CRIME_TYPE'] = unified_crime_type
        df = df.drop(columns=['TYPE'])

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


def location_data(longitude, latitude, neighbourhood, address, crime_rate):
    """
    prepare the location data to insert into location dimension
    :param longitude: (float) X
    :param latitude: (float) Y
    :param neighbourhood: (str) neighbourhood id from the dataframe
    :param address: (str) the address from the dataframe
    :param crime_rate: (float) the average crime rate of the city
    :return: (dict, str) a dictionary containing all info that is inserting into location dimension, location_key dict key
    """
    city = 'Vancouver'
    return {'longitude': longitude, 'latitude': latitude, 'city': city, 'neighbourhood': neighbourhood,
            'address': address, 'crime_rate': crime_rate}, 'location_key'


def crime_data(unified_crime_category, unified_crime_type, report_time, crime_severity) -> (dict, str):
    return {'crime_category': unified_crime_category, 'crime_type': unified_crime_type, 'report_time': report_time,
            'crime_severity': crime_severity}, 'crime_key'


def weather_data(temperature, weather_description, humidity, precipitation):
    return {'temperature': temperature, 'weather_description': weather_description, 'humidity': humidity,
            'precipitation': precipitation}, 'weather_key'


def event_data(event_name, event_type, event_location, event_location_size):
    return {'event_name': event_name, 'event_type': event_type, 'event_location': event_location,
            'event_location_size': event_location_size}, 'event_key'


def fact_data(crime_key, location_key, weather_key, report_date_key, event_key, is_traffic, is_nighttime, is_fatal):
    return {'crime_key': crime_key, 'location_key': location_key, 'weather_key': weather_key,
            'report_date_key': report_date_key,
            'event_key': event_key, 'is_traffic': is_traffic, 'is_nighttime': is_nighttime, 'is_fatal': is_fatal}, '?'


if __name__ == '__main__':
    read_files('../data/vancouver_raw.csv')
    pass
