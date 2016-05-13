#!/bin/bash


# configure /etc/ckan/production.ini
/bin/sh /usr/lib/ckan/bin/ckan_config.sh


if [ "$1" = 'app' ]; then

    # wait for all services to start-up
    if [ "$2" = '--wait-for-dependencies' ]; then
        sh -c "while ! nc -w 1 -z $DB_PORT_5432_TCP_ADDR $DB_PORT_5432_TCP_PORT; do sleep 1; done"
        sh -c "while ! nc -w 1 -z $SOLR_PORT_8983_TCP_ADDR $SOLR_PORT_8983_TCP_PORT; do sleep 1; done"
        sh -c "while ! nc -w 1 -z $REDIS_PORT_6379_TCP_ADDR $REDIS_PORT_6379_TCP_PORT; do sleep 1; done"
    fi

    # initialize DB
    ckan db init
    ckan --plugin=ckanext-harvest harvester initdb

    # Initialize the database tables needed by ckanext-report
    ckan --plugin=ckanext-report report generate

    # start supervisor deamon
    /bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"

elif [ "$1" = 'fetch-consumer' ]; then
    
    # wait for the app to start-up 
    if [ "$2" = '--wait-for-dependencies' ]; then
        sh -c "while ! nc -w 1 -z $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT; do sleep 1; done"
    fi

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester fetch_consumer

elif [ "$1" = 'gather-consumer' ]; then 

    # wait for the app to start-up 
    if [ "$2" = '--wait-for-dependencies' ]; then
        sh -c "while ! nc -w 1 -z $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT; do sleep 1; done"
    fi

    #ckan harvester initdb
    ckan --plugin=ckanext-harvest harvester gather_consumer
else
    # execute any other command
    exec $@
fi
