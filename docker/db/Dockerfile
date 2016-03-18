FROM postgres:9.3

# Install required packages
RUN apt-get -q -y update && apt-get -q -y install \
        postgis \
        postgresql-9.3-postgis-2.1 \
        postgresql-client

COPY prepare_db.sh /docker-entrypoint-initdb.d

#VOLUME /var/lib/postgresql/data

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
