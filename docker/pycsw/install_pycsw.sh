#!/bin/env sh

# Install PyCSW

mkdir -p $PYCSW_WEB/pycsw && cd $PYCSW_WEB/pycsw
git clone https://github.com/geopython/pycsw.git
cd $PYCSW_WEB/pycsw && pip install -r requirements.txt && pip install -e .
cp -a /tmp/pycsw-all.cfg $PYCSW_CONFIG/pycsw-all.cfg
cp -a /tmp/pycsw $PYCSW_CRON/pycsw
cp -a /tmp/pycsw.wsgi $PYCSW_WEB/pycsw.wsgi
rm -R /tmp/pycsw-all.cfg
rm -R /tmp/pycsw.wsgi
exit
