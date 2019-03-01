#!/bin/bash

set -o errexit
set -o pipefail

ckan --plugin=ckanext-spatial spatial initdb

#Add to the plugins list
$CKAN_HOME/bin/paster --plugin=ckan config-tool $CKAN_CONFIG/production.ini -e 'ckan.plugins = harvest ckan_harvester spatial_metadata spatial_query geodatagov_geoportal_harvester geodatagov waf_harvester_collection geodatagov_waf_harvester geodatagov_csw_harvester'

# execute any other command
/bin/bash $@
