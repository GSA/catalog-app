#!/bin/sh
set -e

# configure /etc/ckan/production.ini
/bin/sh /usr/lib/ckan/bin/ckan_config.sh

# initialize db
ckan db init

# set-up pycsw
#/usr/lib/ckan/bin/paster --plugin=ckanext-spatial ckan-pycsw setup -p /etc/ckan/pycsw-all.cfg

# start supervisord
/usr/lib/ckan/bin/supervisord
