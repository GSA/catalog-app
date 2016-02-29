#!/bin/env sh

# Install PyCSW

mkdir -p $PYCSW_WEB/pycsw && cd $PYCSW_WEB/pycsw
git clone https://github.com/geopython/pycsw.git
cd $PYCSW_WEB/pycsw && pip install -r requirements.txt && pip install -e .
cp -a /tmp/default.cfg $PYCSW_CONFIG/default.cfg
cp -a /tmp/pycsw $PYCSW_CRON/pycsw
cp -a /tmp/pycsw.wsgi $PYCSW_WEB/pycsw.wsgi
rm -R /tmp/default.cfg
rm -R /tmp/pycsw.wsgi
exit
