#!/bin/sh
set -e

VIRTUAL_ENV=/usr/lib/ckan

# create virtual_env & upgrade pip
virtualenv $VIRTUAL_ENV -p /root/.localpython/bin/python2.7
$VIRTUAL_ENV/bin/pip install -U pip==8.1.1

# install ckan core + ckan extensions
$VIRTUAL_ENV/bin/pip install -r requirements-freeze.txt

EXTENSIONS=$(cat requirements.txt | grep -o "egg=.*" | cut -f2- -d'=')

# install/setup each extension individually
for extension in $EXTENSIONS; do
    if [ -f $VIRTUAL_ENV/src/$extension/requirements.txt ]; then 
        $VIRTUAL_ENV/bin/pip install -r $VIRTUAL_ENV/src/$extension/requirements.txt
    elif [ -f $VIRTUAL_ENV/src/$extension/pip-requirements.txt ]; then
    	$VIRTUAL_ENV/bin/pip install -r $VIRTUAL_ENV/src/$extension/pip-requirements.txt
    fi
done
