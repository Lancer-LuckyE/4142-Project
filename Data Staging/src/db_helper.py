import psycopg2
from configparser import ConfigParser


def db_config(filename='db_config.ini', section='postgresql'):
    parser = ConfigParser()
    parser.read(filename)

    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))
    return db


def db_connect():
    conn = None
    try:
        params = db_config()
        print("Connecting to the PostgresSQL database...")
        conn = psycopg2.connect(host=params['host'], port=params['port'], database=params['database'],
                                user=params['user'], password=params['password'])
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        return conn


if __name__ == '__main__':
    print(db_connect())