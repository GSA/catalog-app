#!/bin/bash

set -o errexit
set -o pipefail

# Silence ckan_config.sh when not run in a tty (better for piping output)
fd="/dev/stdout"
if [[ ! -t 0 ]]; then
  # Not a tty
  fd=/dev/null
fi

# activate the virutal environment
source /usr/lib/ckan/bin/activate

# If we are to start the gather or fetch process, note that
if [ "$1" = 'gather' ]; then
  set -- "${@:2}"
  gather=true
fi
if [ "$1" = 'fetch' ]; then
  set -- "${@:2}"
  fetch=true
fi

if [ "$gather" = true ]; then
  ckan --plugin=ckanext-harvest harvester gather_consumer
elif [ "$fetch" = true ]; then
  ckan --plugin=ckanext-harvest harvester fetch_consumer
else
  # initialize DB
  ckan db init
  # ckan --plugin=ckanext-harvest harvester initdb
  # ckan --plugin=ckanext-ga-report initdb
  # ckan --plugin=ckanext-archiver archiver init
  # ckan --plugin=ckanext-qa qa init
  # ckan --plugin=ckanext-report report initdb

  # Add default user
  ckan user add data_gov_admin password=password1 email=asdf@asdf.com || true
  ckan sysadmin add data_gov_admin || true

  # Run any extra given arguments as commands
  /bin/bash $@

  # If starting the server, run commands
  source /etc/apache2/envvars
  exec /usr/sbin/apache2 -DFOREGROUND
fi

# activate the virutal environment
# source /usr/lib/ckan/bin/activate
