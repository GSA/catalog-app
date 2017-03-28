#!/bin/sh
set -e

if [ ! -z "$1" ]; then
    VIRTUAL_ENV=$1
else 
    VIRTUAL_ENV=/usr/lib/ckan
fi

# create virtual_env & upgrade pip
if [ -f /usr/local/lib/python2.7.10/bin/python ]; then
    virtualenv $VIRTUAL_ENV -p /usr/local/lib/python2.7.10/bin/python
else
    virtualenv $VIRTUAL_ENV
fi
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
