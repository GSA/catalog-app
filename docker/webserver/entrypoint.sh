#!/bin/bash

set -o errexit
set -o pipefail

# Silence ckan_config.sh when not run in a tty (better for piping output)
fd="/dev/stdout"
if [[ ! -t 0 ]]; then
  # Not a tty
  fd=/dev/null
fi

# configure /etc/ckan/production.ini
ckan_config.sh > $fd

function wait-for-dependencies () {
  local address="$1"
  local port="$2"
  while ! nc -w 1 -z "$address" "$port"; do
    sleep 1;
  done
}


if [ "$1" = 'app' ]; then

    # wait for all services to start-up
    if [ "$2" = '--wait-for-dependencies' ]; then
        wait-for-dependencies db 5432
        wait-for-dependencies solr 8983
        wait-for-dependencies redis 6379
    fi

    # initialize DB
    ckan db init
    ckan --plugin=ckanext-harvest harvester initdb
    ckan --plugin=ckanext-ga-report initdb
    ckan --plugin=ckanext-archiver archiver init
    ckan --plugin=ckanext-qa qa init
    ckan --plugin=ckanext-report report initdb

    source /etc/apache2/envvars
    exec /usr/sbin/apache2 -DFOREGROUND

elif [ "$1" = 'fetch-consumer' ]; then
    
    # wait for the app to start-up 
    if [ "$2" = '--wait-for-dependencies' ]; then
        wait-for-dependencies app 80
    fi

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester fetch_consumer

elif [ "$1" = 'gather-consumer' ]; then 

    # wait for the app to start-up 
    if [ "$2" = '--wait-for-dependencies' ]; then
        wait-for-dependencies app 80
    fi

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester gather_consumer
fi

# activate the virutal environment
source /usr/lib/ckan/bin/activate

# execute any other command
exec "$@"
