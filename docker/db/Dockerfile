FROM ubuntu:14.04

# Install required packages
RUN apt-get -q -y update && apt-get -q -y install \
	postgresql-client \
	postgresql \
        postgis \
        postgresql-9.3-postgis-2.1

USER postgres

RUN /etc/init.d/postgresql start && \
	psql -c "CREATE USER ckan WITH PASSWORD 'pass' SUPERUSER;" && \
	psql -c "CREATE DATABASE ckan OWNER ckan;" && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/rtpostgis.sql && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/topology.sql && \
	psql -d ckan -c "GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan;" && \
	psql -c "SELECT 1 FROM pg_database WHERE datname = 'pycsw';" && \
	psql -c "CREATE DATABASE pycsw OWNER ckan;" && \
	psql -d pycsw -c "CREATE EXTENSION postgis;"

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
