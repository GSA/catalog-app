#!/bin/bash

set -o errexit
set -o pipefail

# Silence ckan_config.sh when not run in a tty (better for piping output)
fd="/dev/stdout"
if [[ ! -t 0 ]]; then
  # Not a tty
  fd=/dev/null
fi

# Add the URL's and passwords from the various services to the CKAN app
#  configuration file
write_config () {
  # Set up DB url
  local user=$DB_CKAN_USER
  local pass=$DB_CKAN_PASSWORD
  local db=$DB_CKAN_DB
  local host='db'
  local port='5432'
  local DATABASE_URL=postgresql://${user}:${pass}@${host}:${port}/${db}

  "$CKAN_HOME"/bin/paster --plugin=ckan config-tool "$1" -e \
      "sqlalchemy.url = ${DATABASE_URL}" \
      "solr_url = http://solr:8983/solr/ckan" \
      "ckan.redis.url = redis://:pass@redis/1"
      # "ckan.harvest.mq.hostname = ${REDIS_PORT_6379_TCP_ADDR}" \
      # "ckanext.geodatagov.fgdc2iso_service = ${FGDC2ISO_URL}"
}

write_config "${CKAN_CONFIG}/production.ini"
write_config "${CKAN_HOME}/src/ckan/test-core.ini"

# Specific variable settings only for production.ini
"$CKAN_HOME"/bin/paster --plugin=ckan config-tool "${CKAN_CONFIG}/production.ini" -e \
  "ckan.harvest.mq.hostname = ${REDIS_PORT_6379_TCP_ADDR}" \
  "ckan.site_url = ${CKAN_SITE_URL}" \
  "ckan.storage_path = /var/lib/ckan"
  # "ckanext.geodatagov.fgdc2iso_service = http://$FGDC2ISO_PORT_8080_TCP_ADDR:$FGDC2ISO_PORT_8080_TCP_PORT/fgdc2iso"

# initialize DB
ckan db init
# ckan --plugin=ckanext-harvest harvester initdb
# ckan --plugin=ckanext-ga-report initdb
# ckan --plugin=ckanext-archiver archiver init
# ckan --plugin=ckanext-qa qa init
# ckan --plugin=ckanext-report report initdb

/bin/bash $@

source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND

# elif [ "$1" = 'fetch-consumer' ]; then
#
#     # wait for the app to start-up
#     if [ "$2" = '--wait-for-dependencies' ]; then
#         wait-for-dependencies $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT
#     fi
#
#     #ckan harvester initdb
#     ckan --plugin=ckanext-harvest harvester fetch_consumer
#
# elif [ "$1" = 'gather-consumer' ]; then
#
#     # wait for the app to start-up
#     if [ "$2" = '--wait-for-dependencies' ]; then
#         wait-for-dependencies $APP_PORT_80_TCP_ADDR $APP_PORT_80_TCP_PORT
#     fi
#
#     #ckan harvester initdb
#     ckan --plugin=ckanext-harvest harvester gather_consumer

# activate the virutal environment
source /usr/lib/ckan/bin/activate
