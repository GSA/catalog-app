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
	libapache2-mod-wsgi \
	python-pip \
	libgeos-c1 \
	libxml2-dev \
	libxslt1-dev \
	lib32z1-dev \
	libpq-dev \
        tomcat6

# copy ckan script to /usr/bin/
COPY common/usr/bin/ckan /usr/bin/ckan

# Install pip
RUN easy_install $PIP_URL && \
	virtualenv $CKAN_HOME --no-site-packages

# CKAN harvester
RUN  $CKAN_HOME/bin/pip install supervisor
COPY harvest/etc/cron.daily/remove_old_sessions /etc/cron.daily/remove_old_sessions
COPY harvest/etc/supervisord.conf /etc/supervisord.conf
COPY harvest/etc/cron.d/* /etc/cron.d/
COPY supervisor/supervisord.conf /etc/supervisord.conf
COPY harvest/etc/init/supervisor.conf /etc/init/supervisor.conf
RUN ln -s $CKAN_HOME/bin/supervisorctl /usr/bin/supervisorctl

# Install CKAN app
RUN git clone https://github.com/GSA/catalog-app.git /tmp/catalog-app && \ 
	cd /tmp/catalog-app && \
	sh install.sh && \
        mkdir -p $CKAN_CONFIG && \
	$CKAN_HOME/bin/pip install repoze.who==2.0

#COPY config/environments/$CKAN_ENV/production.ini $CKAN_CONFIG 
#COPY config/environments/$CKAN_ENV/saml2/who.ini $CKAN_CONFIG
RUN cp /tmp/catalog-app/config/environments/$CKAN_ENV/production.ini $CKAN_CONFIG && \
	cp /tmp/catalog-app/config/environments/$CKAN_ENV/saml2/who.ini $CKAN_CONFIG

CMD ["/usr/lib/ckan/bin/supervisord"]
