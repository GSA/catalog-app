#!/bin/bash

echo "Upgrade DB"
paster --plugin=ckan db upgrade --config=$CKAN_INI