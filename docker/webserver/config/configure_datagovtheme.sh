#!/bin/bash

set -o errexit
set -o pipefail

#Add to the plugins list
$CKAN_HOME/bin/paster --plugin=ckan config-tool $CKAN_CONFIG/production.ini -e 'ckan.plugins = datagovtheme'

# execute any other command
/bin/bash $@
