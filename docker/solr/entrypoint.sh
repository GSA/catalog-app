#!/bin/bash
set -e

/opt/solr/bin/solr start
# for some reason the solr daemon needs to be running to create the core + attach schema.xml
# we restart the service at the end for this reason.
/opt/solr/bin/solr create_core -c ckan
/opt/solr/bin/post -c ckan /schema.xml
/opt/solr/bin/solr restart -f
