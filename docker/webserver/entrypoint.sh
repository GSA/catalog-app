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
/bin/sh /usr/lib/ckan/bin/ckan_config.sh > $fd

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
        wait-for-dependencies $DB_PORT_5432_TCP_ADDR $DB_PORT_5432_TCP_PORT
        wait-for-dependencies $SOLR_PORT_8983_TCP_ADDR $SOLR_PORT_8983_TCP_PORT
        wait-for-dependencies $REDIS_PORT_6379_TCP_ADDR $REDIS_PORT_6379_TCP_PORT
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
        wait-for-dependencies $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT
    fi

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester fetch_consumer

elif [ "$1" = 'gather-consumer' ]; then 

    # wait for the app to start-up 
    if [ "$2" = '--wait-for-dependencies' ]; then
        wait-for-dependencies $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT
    fi

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester gather_consumer
fi

# activate the virutal environment
source /usr/lib/ckan/bin/activate

# execute any other command
exec "$@"
