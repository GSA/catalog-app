#!/bin/env sh

# Install PyCSW

mkdir -p /var/www/pycsw && cd /var/www/pycsw
git clone https://github.com/geopython/pycsw.git
cd /var/www/pycsw && pip install -r requirements.txt && pip install -e .
cp -a /tmp/default.cfg /var/www/pycsw/default.cfg
rm -R /tmp/default.cfg
exit
