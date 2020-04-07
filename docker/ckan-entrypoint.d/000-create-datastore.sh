#!/bin/bash

echo "Create datastore DB"
psql -h db -U postgres -c "CREATE DATABASE datastore OWNER ckan;"

echo "Create RO user for datastore"
psql -h db -U postgres -c "CREATE USER datastore_ro WITH PASSWORD 'datastore';"
psql -h db -U postgres -d ckan -c "GRANT SELECT ON datastore TO datastore_ro;"

