#!/bin/bash

set -o errexit
set -o pipefail
# set -o nounset # This option conflicts with the use of regex matching and $BASH_REMATCH

# At this point we expect that you've already done:
#   cf set-env <appname> DS_RO_USER <datastore_username>
#   cf set-env <appname> DS_RO_PASSWORD <datastore_password>
#   cf set-env <appname> SOLR_URL <solr_url>

echo "VCAP_APPLICATION = $(echo $VCAP_APPLICATION | jq .)"
echo "VCAP_SERVICES = $(echo $VCAP_SERVICES | jq .)"

mkdir -p /var/tmp/ckan/dynamic_menu
touch /var/tmp/ckan/dynamic_menu/menu.json

CKAN_INI=config/environments/prod/production.ini

# We need to know the application name ...

APP_NAME=$(echo $VCAP_APPLICATION | jq -r '.application_name')

# ... from which we can guess the service names

SVC_DATABASE="${APP_NAME}-db"
SVC_REDIS="${APP_NAME}-redis"

# Grab database url from the VCAP_SERVICES env var provided by the platform

DATABASE_URL=$(echo $VCAP_SERVICES | jq -r --arg SVC_DATABASE $SVC_DATABASE '.["aws-rds"][] | select(.name == $SVC_DATABASE) | .credentials.uri')

# Grab redis settings

REDIS_HOSTNAME=$(echo $VCAP_SERVICES | jq -r --arg SVC_REDIS $SVC_REDIS '.["redis32"][] | select(.name == $SVC_REDIS) | .credentials.hostname')
REDIS_PORT=$(echo $VCAP_SERVICES | jq -r --arg SVC_REDIS $SVC_REDIS '.["redis32"][] | select(.name == $SVC_REDIS) | .credentials.port')
REDIS_PASSWORD=$(echo $VCAP_SERVICES | jq -r --arg SVC_REDIS $SVC_REDIS '.["redis32"][] | select(.name == $SVC_REDIS) | .credentials.password')

echo "Setting up PostGIS"
DATABASE_URL=$DATABASE_URL ./configure-postgis.py

# Edit the config file to use our values
paster --plugin=ckan config-tool $CKAN_INI -s server:main -e port=${PORT}
paster --plugin=ckan config-tool $CKAN_INI \
    "sqlalchemy.url=${DATABASE_URL}" \
    "solr_url=${SOLR_URL}" \
    "ckanext.geodatagov.fgdc2iso_service=${FGDC2ISO_URL}" \
    "ckan.harvest.mq.hostname=${REDIS_HOSTNAME}" \
    "ckan.harvest.mq.port=${REDIS_PORT}" \
    "ckan.harvest.mq.password=${REDIS_PASSWORD}"

# Initialize DB

echo "Clearing plugins"
paster --plugin=ckan config-tool $CKAN_INI ckan.plugins=

echo "Initializing db"
paster --plugin=ckan db init -c $CKAN_INI

#     "ckan.plugins=stats text_view image_view recline_view datagov_harvest ckan_harvester z3950_harvester resource_proxy recline_preview datagovtheme datajson_harvest datajson archiver qa googleanalyticsbasic extlink saml2 report broken_link_report"
#
# REMIND: this list depends on PostGIS
#


echo "Restoring plugins"
paster --plugin=ckan config-tool $CKAN_INI \
       "ckan.plugins=stats text_view image_view recline_view geodatagov datagov_harvest ckan_harvester geodatagov_geoportal_harvester z3950_harvester arcgis_harvester waf_harvester_collection geodatagov_csw_harvester geodatagov_doc_harvester geodatagov_waf_harvester spatial_metadata spatial_query resource_proxy spatial_harvest_metadata_api recline_preview datagovtheme datajson_harvest datajson archiver qa googleanalyticsbasic extlink saml2 report broken_link_report"

# Run migrations
echo "Running migrations"
paster --plugin=ckan db upgrade -c $CKAN_INI

# TODO: This only applies for development; in staging and production SAML should be configured!
# In order to work around https://github.com/GSA/catalog-app/issues/78 we need PIP to make a package change
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
python /tmp/get-pip.py
pip install -U repoze.who==2.0

# Fire it up!
echo "Starting ckan"
exec paster --plugin=ckan serve $CKAN_INI

