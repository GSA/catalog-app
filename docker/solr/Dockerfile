FROM solr:5.4

COPY schema.xml /opt/solr/server/solr/configsets/basic_configs/conf
COPY schema.xml /opt/solr/example/solr/ckan/conf/schema.xml

RUN /opt/solr/bin/solr start && \
    /opt/solr/bin/solr create_core -c ckan -d basic_configs

VOLUME /var/lib/solr
