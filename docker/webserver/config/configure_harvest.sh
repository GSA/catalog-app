#!/bin/bash

set -o errexit
set -o pipefail

ckan --plugin=ckanext-spatial spatial initdb

ckan --plugin=ckanext-harvest harvester initdb

# Add to the plugins list
# $CKAN_HOME/bin/paster --plugin=ckan config-tool $CKAN_CONFIG/production.ini -e 'ckan.plugins = stats text_view image_view recline_view geodatagov datagov_harvest ckan_harvester geodatagov_geoportal_harvester arcgis_harvester waf_harvester_collection geodatagov_csw_harvester geodatagov_doc_harvester geodatagov_waf_harvester spatial_metadata spatial_query resource_proxy spatial_harvest_metadata_api recline_preview datagovtheme'
$CKAN_HOME/bin/paster --plugin=ckan config-tool $CKAN_CONFIG/production.ini -e 'ckan.plugins = stats text_view image_view recline_view geodatagov datagov_harvest ckan_harvester geodatagov_geoportal_harvester arcgis_harvester waf_harvester_collection geodatagov_csw_harvester geodatagov_doc_harvester geodatagov_waf_harvester spatial_metadata spatial_query resource_proxy spatial_harvest_metadata_api recline_preview datajson datajson_harvest'

# execute any other command
/bin/bash $@
