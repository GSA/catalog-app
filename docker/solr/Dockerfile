FROM solr:latest
USER root

COPY entrypoint.sh /entrypoint.sh
COPY schema.xml /schema.xml
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
