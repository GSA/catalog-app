FROM ubuntu:14.04

ENV HOME /root
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_ENV develop
ENV SOLR_URL http://packages.reisys.com/ckan/solr/solr-4.2.1.tgz
ENV PIP_URL https://pypi.python.org/packages/source/p/pip/pip-1.3.1.tar.gz 

# Install required packages
RUN apt-get -q -y update && apt-get -q -y install \
	htop \
	atool \
	ruby \
	python-virtualenv \
	python-setuptools \
	git \
	python-dev \
	ruby-dev \
	postgresql-client \
	bison \
	apache2 \
	libapache2-mod-wsgi \
	python-pip \
	redis-server \
	libgeos-c1 \
	libxml2-dev \
	libxslt1-dev \
	lib32z1-dev \
	libpq-dev \
        tomcat6 \
        postgresql \
        postgis \
        postgresql-9.3-postgis-2.1
        #memcached \
        #m2crypto \
        #xmlsec1 \
        #swig

# copy ckan script to /usr/bin/
COPY docker/common/usr/bin/ckan /usr/bin/ckan

# Install pip
RUN easy_install name=$PIP_URL


# Install CKAN app
RUN sh install.sh
COPY config/environments/$CKAN_ENV/production.ini $CKAN_CONFIG 
COPY config/environments/$CKAN_ENV/saml2/who.ini $CKAN_CONFIG

# fix saml2
RUN pip install repoze.who==2.0

# Configure apache
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
COPY docker/apache/apache.wsgi $CKAN_CONFIG
COPY docker/apache/ckan.conf /etc/apache2/sites-enabled
RUN a2enmod rewrite headers && service apache2 restart

# Restart postgres

# Install SOLR
RUN cd /tmp && \
	wget -T 40 $SOLR_URL && \
	tar -zxvf solr-4.2.1.tgz && \ 
	cd solr-4.2.1/dist && \
	cp solr-4.2.1.war /var/lib/tomcat6/webapps/solr.war && \
	mkdir -p /home/solr && \
	cp -R solr-4.2.1/example/solr/* /home/solr && \
	rm -r /home/solr/ckan && \
	mv /home/solr/collection1 /home/solr/ckan

COPY docker/solr/solr.xml
COPY docker/solr/web.xml /var/lib/tomcat6/webapps/solr/WEB-INF/web.xml
COPY docker/solr/schema.xml /home/solr/ckan/conf/schema.xml
RUN chown -R tomcat6 /home/solr && service tomcat6 restart

# CKAN DB
RUN /etc/init.d/postgresql restart && \
	su postgres && \
	psql -c "CREATE USER ckan WITH PASSWORD 'pass' SUPERUSER;" && \
	psql -c "CREATE DATABASE ckan OWNER ckan;" && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/rtpostgis.sql && \
	psql -d ckan -f /usr/share/postgresql/9.3/contrib/postgis-2.1/topology.sql && \
	psql -d ckan -c "GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan;" && \
	ckan db init

# CKAN harvester
RUN pip name=supervisor virtualenv=$CKAN_HOME
COPY docker/harvest/etc/cron.daily/remove_old_sessions /etc/cron.daily/remove_old_sessions
COPY docker/harvest/etc/supervisord.conf /etc/supervisord.conf
COPY docker/harvest/etc/cron.d/ckan-harvest /etc/cron.d/ckan-harvest
COPY docker/harvest/etc/cron.d/supervisor /etc/cron.d/supervisor
COPY docker/harvest/etc/supervisord.conf /etc/supervisord.conf
COPY docker/harvest/etc/init/supervisor.conf /etc/init/supervisor.conf
RUN ln -s $CKAN_HOME/bin/supervisorctl /usr/bin/supervisorctl && \
	service supervisor start 
		
EXPOSE 80
