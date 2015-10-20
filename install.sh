#!/bin/sh

VIRTUAL_ENV=/usr/lib/ckan

# create virtual_env
virtualenv $VIRTUAL_ENV --no-site-packages

# switch to virtual env
. $VIRTUAL_ENV/bin/activate

# install ckan core + ckan extensions
pip install -r requirements.txt --build=$VIRTUAL_ENV/src/

# `pip install -r requirements.txt` + run `python setup.py` on each extension
cat requirements.txt | grep -o "egg=.*" | cut -f2- -d'=' | xargs -I {} pip install -r $VIRTUAL_ENV/src/{}/requirements.txt
cat requirements.txt | grep -o "egg=.*" | cut -f2- -d'=' | xargs -I {} python $VIRTUAL_ENV/src/{}/setup.py develop
