#!/bin/bash

echo "Init DB for ckanext-harvest"
paster --plugin=ckanext-harvest harvester initdb $CKAN_INI