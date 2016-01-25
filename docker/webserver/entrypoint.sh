#!/bin/bash
#set -e

# configure /etc/ckan/production.ini
/bin/sh /usr/lib/ckan/bin/ckan_config.sh


if [ -z "$1" ]; then
    #sh -c "while nc -w 1 -z ckan-db-init 5555; do sleep 1; done"
    exec /usr/lib/ckan/bin/supervisord 
elif [ "$1" = 'fetch-consumer' ]; then
    # workaround, this process needs an initialized db before it can be run
    # it will fail at start up, but should be up and running after a 1 sec sleep
    until ckan --plugin=ckanext-harvest harvester fetch_consumer #> /var/log/fetch-consumer.log
    do
        sleep 1
    
    done
elif [ "$1" = 'gather-consumer' ]; then 
    # workaround, this process needs an initialized db before it can be run
    # it will fail at start up, but should be up and running after a 1 sec sleep
    until ckan --plugin=ckanext-harvest harvester gather_consumer #> /var/log/gather-consumer.log
    do
        sleep 1
    done
    
elif [ "$1" = 'ckan-db-init' ]; then 
    ckan db init
fi

# set-up pycsw
#/usr/lib/ckan/bin/paster --plugin=ckanext-spatial ckan-pycsw setup -p /etc/ckan/pycsw-all.cfg
