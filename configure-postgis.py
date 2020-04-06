#!/usr/bin/python

#
# Enable the PostGIS extension
#

import os
import psycopg2
import re
import sys
from urlparse import urlparse

def identifier(s):
    """
    Return s as a double-quoted string (good for psql identifiers)
    """
    return u'"' + s.replace(u'"', u'""').replace(u'\0', '') + u'"'

def postgis_sql(user):
    return """
        CREATE EXTENSION IF NOT EXISTS postgis;
        CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
        CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        CREATE EXTENSION IF NOT EXISTS postgis_topology;
        ALTER SCHEMA tiger OWNER TO {user};
        ALTER SCHEMA tiger_data OWNER TO {user};
        ALTER SCHEMA topology OWNER TO {user};
        CREATE FUNCTION exec(text) RETURNS text LANGUAGE PLPGSQL VOLATILE AS $f$ BEGIN EXECUTE $1; RETURN $1; END; $f$;                              
        SELECT exec('ALTER TABLE ' || quote_ident(s.nspname) || '.' || quote_ident(s.relname) || ' OWNER TO {user};')
            FROM (
                SELECT nspname, relname
                FROM pg_class c JOIN pg_namespace n ON (c.relnamespace = n.oid) 
                WHERE nspname IN ('tiger','topology', 'tiger_data') AND
            relkind IN ('r','S','v') ORDER BY relkind = 'S')
        s;  

        SET search_path=public,tiger;

    """.format(user=identifier(user))

def get_env(name):
    if name not in os.environ:
        raise Exception("Required environment variable %s is missing" % name)
    value = os.environ[name]
    if not value:
        raise Exception("Environment variable %s missing value" % name)
    return value

def main():
    database_url = get_env('DATABASE_URL')
    database = urlparse(database_url)
    user = database.username
    
    sql = postgis_sql(user)

    print "<SQL>"
    print sql
    print "</SQL>"

    try:
        with psycopg2.connect(database_url) as conn:
            try:
                with conn.cursor() as cur:
                    cur.execute(sql)
            except Exception as sql_e:
                print "Exception while executing SQL:", str(sql_e)
    except Exception as conn_e:
        print "Unable to connect to database:", str(conn_e)
        sys.exit(-1)

if __name__ == '__main__':
    main()
