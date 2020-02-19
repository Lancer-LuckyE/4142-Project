import pandas as pd
import denver_data_cleaning as den
import vancouver_data_cleaning as van


def creat_dimensions():
    """
    create all dimensions
    :return:(dataframes) date dimension, location dimension, crime dimension, weather dimension, event dimension, fact dimension
    """
    date_cols = ['date_key', 'crime_date', 'day_of_the_week', 'week_of_the_year', 'quarter', 'weekend', 'holiday',
                 'holiday_name']
    location_cols = ['location_key', 'longitude', 'latitude', 'city', 'neighbourhood', 'address', 'population',
                     'crime_rate']
    crime_cols = ['crime_key', 'crime_category', 'crime_type', 'first_occurrence_time', 'last_occurrence_time',
                  'report_time', 'crime_severity']
    weather_cols = ['weather_key', 'temperature', 'main_weather', 'weather_description', 'humidity']
    event_cols = ['event_key', 'event_name', 'event_type', 'event_location', 'event_location_size']
    fact_cols = ['crime_key', 'location_key', 'weather_key', 'first_occurrence_date_key', 'last_occurrence_date_key',
                 'report_date_key', 'event_key', 'is_traffic', 'is_nighttime', 'is_fatal']
    return pd.DataFrame(columns=date_cols), pd.DataFrame(columns=location_cols), pd.DataFrame(
        columns=crime_cols), pd.DataFrame(columns=weather_cols), pd.DataFrame(columns=event_cols), pd.DataFrame(
        columns=fact_cols)


def insert_data(dimension: pd.DataFrame, data: dict, key: str):
    """
    insert data into a dimension
    :param dimension:(dataframe) one of the dimensions created from create_dimensions
    :param data:(dict) the data gathered from XX_data
    :param key:(str) the returned key from the XX_data
    :return:(dataframe) the dimension dataframe with the data inserted
    """

    def _exist(df: pd.DataFrame, data: dict):
        """Examine if there is already a row with complete same data in df"""
        if len(df.index) != 0:
            df = df.drop(df.columns[0], axis=1)
            to_insert = pd.DataFrame(data, index=[0])
            for idx, row in df.iterrows():
                insert_tmp = to_insert.iloc[0]
                if insert_tmp.equals(row):
                    return True, idx + 1
            return False, -1
        else:
            return False, -1

    if data is not None:
        val = len(dimension.index) + 1
        existed, dup_key = _exist(df=dimension, data=data)
        if existed:
            return dimension, dup_key
        else:
            data[key] = val
            dimension = dimension.append(data, ignore_index=True)
        return dimension, val
    else:
        return dimension, len(dimension.index)


def main():
    date_dimension, location_dimension, crime_dimension, weather_dimension, event_dimension, fact_dimension = creat_dimensions()

    print('read files ...')
    denver_df, weather_df, event_df = den.read_files('../data/denver_crime.csv')
    for index, row in denver_df.iterrows():
        print('\n\ninserting date ...')
        date_data, date_key = den.date_data(row['FIRST_OCCURRENCE_DATE'])
        date_dimension, date_f_key = insert_data(date_dimension, date_data, date_key)
        print('Done Date_f: ' + str(date_f_key))
        date_data, date_key = den.date_data(row['LAST_OCCURRENCE_DATE'])
        date_dimension, date_l_key = insert_data(date_dimension, date_data, date_key)
        print('Done Date_l: ' + str(date_l_key))
        date_data, date_key = den.date_data(row['REPORTED_DATE'])
        date_dimension, date_r_key = insert_data(date_dimension, date_data, date_key)
        print('Done Date_r: ' + str(date_r_key))

        print('inserting crime ...')
        crime_data, crime_key = den.crime_data(row['OFFENSE_CATEGORY_ID'], row['OFFENSE_TYPE_ID'], row['TIME_F'],
                                               row['TIME_L'], row['TIME_R'])
        crime_dimension, crime_key = insert_data(crime_dimension, crime_data, crime_key)
        print('Done Crime: ' + str(crime_key))

        print('inserting location ...')
        location_data, location_key = den.location_data(row['GEO_LON'], row['GEO_LAT'], row['NEIGHBORHOOD_ID'],
                                                        row['INCIDENT_ADDRESS'], row['CRIME_RATE'])
        location_dimension, location_key = insert_data(location_dimension, location_data, location_key)
        print('Done Location: ' + str(location_key))

        print('inserting weather ...')
        weather_data, weather_key = den.weather_data(row['DATE_F'], row['TIME_F'], weather_df)
        weather_dimension, weather_key = insert_data(weather_dimension, weather_data, weather_key)
        print('Done Weather: ' + str(weather_key))

        print('inserting event ...')
        event_data, event_key = den.event_data(row['DATE_F'], event_df)
        event_dimension, event_key = insert_data(event_dimension, event_data, event_key)
        print('Done event: ' + str(event_key))

        print('inserting fact ...')
        fact_data, fact_key = den.fact_data(crime_key, location_key, weather_key, date_f_key, date_l_key, date_r_key,
                                            event_key, row['IS_TRAFFIC'], row['TIME_F'], row['OFFENSE_CATEGORY_ID'],
                                            row['OFFENSE_TYPE_ID'])
        fact_dimension, fact_key = insert_data(fact_dimension, fact_data, fact_key)
        print('Done Fact: ' + str(fact_key))

    van_df = van.read_files('../data/van_crime.csv')
    for index, row in van_df.iterrows():
        print('\n\ninserting date ...')
        date_data, date_key = van.date_data(row['DATETIME'])
        date_dimension, date_r_key = insert_data(date_dimension, date_data, date_key)
        print('Done Date_r: ' + str(date_r_key))

        print('inserting crime ...')
        crime_data, crime_key = van.crime_data(row['TYPE'], row['TIME_R'])
        crime_dimension, crime_key = insert_data(crime_dimension, crime_data, crime_key)
        print('Done Crime: ' + str(crime_key))

        print('inserting location ...')
        location_data, location_key = van.location_data(row['X'], row['Y'], row['NEIGHBOURHOOD'], row['HUNDRED_BLOCK'],
                                                        row['CRIME_RATE'])
        location_dimension, location_key = insert_data(location_dimension, location_data, location_key)
        print('Done Location: ' + str(location_key))

        print('inserting weather ...')
        weather_data, weather_key = van.weather_data(row['DATE_R'], row['TIME_R'], weather_df)
        weather_dimension, weather_key = insert_data(weather_dimension, weather_data, weather_key)
        print('Done Weather: ' + str(weather_key))

        print('inserting event ...')
        event_data, event_key = van.event_data(row['DATE_R'], event_df)
        event_dimension, event_key = insert_data(event_dimension, event_data, event_key)
        print('Done event: ' + str(event_key))

        print('inserting fact ...')
        fact_data, fact_key = van.fact_data(crime_key, location_key, weather_key, None, None, date_r_key,
                                            event_key, row['TIME_R'], row['TYPE'])
        fact_dimension, fact_key = insert_data(fact_dimension, fact_data, fact_key)
        print('Done Fact: ' + str(fact_key))

    print('\n\n\n\n\n')
    for index, row in fact_dimension.iterrows():
        print(row)


if __name__ == '__main__':
    main()
