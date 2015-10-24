#!/bin/sh
su postgres -c "psql -c \"CREATE USER ckan WITH PASSWORD 'pass' SUPERUSER;\""
su postgres -c "psql -c \"CREATE DATABASE ckan OWNER ckan;\""
su postgres -c "psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql"
su postgres -c "psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql"
su postgres -c "psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/rtpostgis.sql"
su postgres -c "psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/topology.sql"
su postgres -c "psql -d ckan -c \"GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan;\""
ckan db init
