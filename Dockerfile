FROM ubuntu:14.04

ENV HOME /root
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_CONFIG /etc/ckan/
ENV CKAN_ENV docker
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
	libgeos-c1 \
	libxml2-dev \
	libxslt1-dev \
	lib32z1-dev \
	libpq-dev \
        tomcat6 \
        default-jdk \
	wget
        #memcached \
        #m2crypto \
        #xmlsec1 \
        #swig

# copy ckan script to /usr/bin/
COPY docker/webserver/common/usr/bin/ckan /usr/bin/ckan

# Install pip
RUN easy_install $PIP_URL && \
	virtualenv $CKAN_HOME --no-site-packages


# Configure apache
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
COPY docker/webserver/apache/apache.wsgi $CKAN_CONFIG
COPY docker/webserver/apache/ckan.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite headers 

# CKAN harvester
RUN  $CKAN_HOME/bin/pip install supervisor
COPY docker/webserver/harvest/etc/cron.daily/remove_old_sessions /etc/cron.daily/remove_old_sessions
COPY docker/webserver/supervisor/supervisord.conf /etc/supervisord.conf
COPY docker/webserver/harvest/etc/cron.d/* /etc/cron.d/
COPY docker/webserver/supervisor/supervisord.conf /etc/supervisord.conf
COPY docker/webserver/harvest/etc/init/supervisor.conf /etc/init/supervisor.conf

RUN ln -s $CKAN_HOME/bin/supervisorctl /usr/bin/supervisorctl

# Install & Configure CKAN app
COPY install.sh /tmp/
COPY requirements.txt /tmp/
COPY docker/webserver/config/ckan_config.sh $CKAN_HOME/bin/
COPY docker/webserver/config/pycsw_config.sh $CKAN_HOME/bin/

RUN cd /tmp && \
	sh install.sh && \
        mkdir -p $CKAN_CONFIG && \
	$CKAN_HOME/bin/pip install repoze.who==2.0

# Config CKAN app
COPY config/environments/$CKAN_ENV/production.ini $CKAN_CONFIG 
COPY config/environments/$CKAN_ENV/saml2/who.ini $CKAN_CONFIG
COPY docker/webserver/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
