#!/bin/bash

# wait for all services to start-up
sh -c "while ! nc -w 1 -z $DB_PORT_5432_TCP_ADDR $DB_PORT_5432_TCP_PORT; do sleep 1; done"
sh -c "while ! nc -w 1 -z $SOLR_PORT_8983_TCP_ADDR $SOLR_PORT_8983_TCP_PORT; do sleep 1; done"
sh -c "while ! nc -w 1 -z $REDIS_PORT_6379_TCP_ADDR $REDIS_PORT_6379_TCP_PORT; do sleep 1; done"

# configure /etc/ckan/production.ini
/bin/sh /usr/lib/ckan/bin/ckan_config.sh


if [ -z "$1" ]; then
    # initialize DB
    ckan db init

    # start supervisor deamon
    exec /usr/lib/ckan/bin/supervisord 

elif [ "$1" = 'fetch-consumer' ]; then
    # wait for the app to start-up 
    sh -c "while ! nc -w 1 -z $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT; do sleep 1; done"

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester fetch_consumer

elif [ "$1" = 'gather-consumer' ]; then 
    # wait for the app to start-up 
    sh -c "while ! nc -w 1 -z $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT; do sleep 1; done"

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester gather_consumer
else 
    # execute any other command
    exec $@
fi

# set-up pycsw
#/usr/lib/ckan/bin/paster --plugin=ckanext-spatial ckan-pycsw setup -p /etc/ckan/pycsw-all.cfg
