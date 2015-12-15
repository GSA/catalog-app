#!/bin/sh
set -e

VIRTUAL_ENV=/usr/lib/ckan

# create virtual_env
virtualenv $VIRTUAL_ENV

# install ckan core + ckan extensions
$VIRTUAL_ENV/bin/pip install -r requirements.txt

EXTENSIONS=$(cat requirements.txt | grep -o "egg=.*" | cut -f2- -d'=')

# install/setup each extension individually
for extension in $EXTENSIONS; do
    if [ -f $VIRTUAL_ENV/src/$extension/requirements.txt ]; then 
        $VIRTUAL_ENV/bin/pip install -r $VIRTUAL_ENV/src/$extension/requirements.txt
    elif [ -f $VIRTUAL_ENV/src/$extension/pip-requirements.txt ]; then
    	$VIRTUAL_ENV/bin/pip install -r $VIRTUAL_ENV/src/$extension/pip-requirements.txt
    fi
done

# set folder permission before we move the whole thing to right location
mkdir -p /usr/lib/ckan/src/ckanext-datagovtheme/ckanext/datagovtheme/dynamic_menu
chmod  -R a+rw /usr/lib/ckan/src/ckanext-datagovtheme/ckanext/datagovtheme/dynamic_menu
