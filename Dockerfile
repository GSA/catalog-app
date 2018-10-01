FROM ubuntu:14.04

ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_CONFIG /etc/ckan/
ENV CKAN_ENV docker

WORKDIR /opt/catalog-app

# TODO compile python to /usr/local to avoid this
# https://github.com/GSA/datagov-deploy/issues/390
ENV LD_LIBRARY_PATH /usr/local/lib/python2.7.10/lib

# Install required packages
RUN apt-get -q -y update && apt-get -q -y install \
  apache2 \
  atool \
  bison \
  default-jdk \
  git \
  htop \
  lib32z1-dev \
  libapache2-mod-wsgi \
  libgeos-c1 \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  memcached \
  postgresql-client \
  python-dev \
  python-pip \
  python-setuptools \
  python-virtualenv \
  ruby \
  ruby-dev \
  swig \
  tomcat6 \
  wget \
  xmlsec1

# copy ckan script to /usr/bin/
COPY docker/webserver/common/usr/bin/ckan /usr/bin/ckan

# Get python 2.7.10 for virtualenv
RUN wget http://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
RUN tar -zxvf Python-2.7.10.tgz
RUN cd Python-2.7.10 && \
    ./configure --prefix=/usr/local/lib/python2.7.10/ --enable-ipv6 --enable-unicode=ucs4 --enable-shared && \
    make && make install

# Upgrade pip & install virtualenv
RUN pip install virtualenv

# Configure apache
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
COPY docker/webserver/apache/apache.wsgi $CKAN_CONFIG
COPY docker/webserver/apache/ckan.conf /etc/apache2/sites-enabled/
COPY docker/webserver/apache/wsgi.conf /etc/apache2/mods-available/
RUN a2enmod rewrite headers

# Install & Configure CKAN app
COPY install.sh /
COPY requirements-freeze.txt /
COPY docker/webserver/config/ckan_config.sh $CKAN_HOME/bin/

# Config CKAN app
COPY config/environments/$CKAN_ENV/production.ini $CKAN_CONFIG
COPY docker/webserver/entrypoint.sh /entrypoint.sh
RUN ln -s $CKAN_HOME/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini
RUN mkdir /var/tmp/ckan && chown www-data:www-data /var/tmp/ckan

# Install ckan app
RUN cd / && ./install.sh

# auth_tkt (and ckan) requires repoze.who 2.0. ckanext-saml, used for
# production requires repoze.who==1.0.18
# installing the one-off repoze.who will upgrade Paste if no version is
# specified. ckanext-geodatagov is not compatible with Paste>=2.0
RUN $CKAN_HOME/bin/pip install -U repoze.who==2.0 Paste==1.7.5.1

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# apache
EXPOSE 80

# paster
EXPOSE 5000

CMD ["app","--wait-for-dependencies"]
