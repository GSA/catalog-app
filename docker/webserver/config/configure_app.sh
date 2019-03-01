#!/bin/bash

set -o errexit

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

echo $DB_CKAN_USER

write_config "${CKAN_CONFIG}/production.ini"
write_config "${CKAN_HOME}/src/ckan/test-core.ini"

# Specific variable settings only for production.ini
"$CKAN_HOME"/bin/paster --plugin=ckan config-tool "${CKAN_CONFIG}/production.ini" -e \
  "ckan.site_url = ${CKAN_SITE_URL}" \
  "ckan.storage_path = /var/lib/ckan"
  # "ckanext.geodatagov.fgdc2iso_service = http://$FGDC2ISO_PORT_8080_TCP_ADDR:$FGDC2ISO_PORT_8080_TCP_PORT/fgdc2iso"
