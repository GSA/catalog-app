#!/bin/bash

set -o errexit
set -o pipefail

# Silence ckan_config.sh when not run in a tty (better for piping output)
fd="/dev/stdout"
if [[ ! -t 0 ]]; then
  # Not a tty
  fd=/dev/null
fi

# Run any extra given arguments as commands
/bin/bash $@

# activate the virutal environment
source /usr/lib/ckan/bin/activate

ckan --plugin=ckanext-harvest harvester fetch_consumer
