FROM solr:latest

COPY schema.xml /schema.xml

RUN /opt/solr/bin/solr start && \
    /opt/solr/bin/solr create_core -c ckan && \
    /opt/solr/bin/post -c ckan /schema.xml

EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER
CMD ["/opt/solr/bin/solr", "-f"]
