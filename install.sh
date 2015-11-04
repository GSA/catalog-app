#!/bin/sh
set -e

VIRTUAL_ENV=ckan
EXTENSIONS=$(cat requirements.txt | grep -o "egg=.*" | cut -f2- -d'=')

# install/setup each extension individually
for extension in $EXTENSIONS; do
    if [ -f $VIRTUAL_ENV/src/$extension/requirements.txt ]; then 
        $VIRTUAL_ENV/bin/pip install -r $VIRTUAL_ENV/src/$extension/requirements.txt
    elif [ -f $VIRTUAL_ENV/src/$extension/pip-requirements.txt ]; then
    	$VIRTUAL_ENV/bin/pip install -r $VIRTUAL_ENV/src/$extension/pip-requirements.txt
    fi
done
