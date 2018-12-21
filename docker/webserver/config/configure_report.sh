#!/bin/bash

set -o errexit
set -o pipefail

#Initialize the DB
ckan --plugin=ckanext-report report initdb

#Add to the plugins list
$CKAN_HOME/bin/paster --plugin=ckan config-tool $CKAN_CONFIG/production.ini -e 'ckan.plugins = report'

# execute any other command
/bin/bash $@
