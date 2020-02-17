import pandas as pd
from datetime import datetime
import holidays
import math
import json


def creat_dimensions():
    """
    create all dimensions
    :return:(dataframes) date dimension, location dimension, crime dimension, weather dimension, event dimension, fact dimension
    """
    date_cols = ['date_key', 'crime_date', 'day_of_the_week', 'week_of_the_year', 'quarter', 'weekend', 'holiday',
                 'holiday_name']
    location_cols = ['location_key', 'longitude', 'latitude', 'city', 'neighbourhood', 'address', 'crime_rate']
    crime_cols = ['crime_key', 'crime_category', 'crime_type', 'first_occurence_time'  'last_occurence_time',
                  'report_time', 'crime_severity']
    weather_cols = ['weather_key', 'temperature', 'visibility', 'weather_description', 'humidity', 'precipitation']
    event_cols = ['event_key', 'event_name', 'event_type', 'event_location', 'event_location_size']
    fact_cols = ['crime_key', 'location_key', 'weather_key', 'first_occurrence_date_key', 'last_occurrence_date_key',
                 'report_date_key', 'event_key', 'is_traffic', 'is_nighttime', 'is_fatal']
    return pd.DataFrame(columns=date_cols), pd.DataFrame(columns=location_cols), pd.DataFrame(
        columns=crime_cols), pd.DataFrame(columns=weather_cols), pd.DataFrame(columns=event_cols), pd.DataFrame(
        columns=fact_cols)


def insert_data(dimension, data, key):
    """
    insert data into a dimension
    :param dimension:(dataframe) one of the dimensions created from create_dimensions
    :param data:(dict) the data gathered from XX_data
    :param key:(str) the returned key from the XX_data
    :return:(dataframe) the dimension dataframe with the data inserted
    """
    val = len(dimension.index) + 1
    data[key] = val
    dimension = dimension.append(data, ignore_index=True)
    return dimension


def main():
    date_dimension, location_dimension, crime_dimension, weather_dimension, event_dimension, fact_dimension = creat_dimensions()

    # date = vancouver_df['DATETIME'][530649]
    # data, key = date_data(date)
    # date_dimension = insert_data(date_dimension, data, key)


if __name__ == '__main__':
    main()
