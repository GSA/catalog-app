FROM ubuntu:14.04

ARG PYTHON_VERSION=2.7.10
ARG REQUIREMENTS_FILE=requirements.txt

ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_CONFIG /etc/ckan/
ENV CKAN_ENV docker

# TODO compile python to /usr/local to avoid this
# https://github.com/GSA/datagov-deploy/issues/390
ENV LD_LIBRARY_PATH /usr/local/lib/python$PYTHON_VERSION/lib

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

# Get custom python version for virtualenv
RUN wget http://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
RUN tar -zxvf Python-$PYTHON_VERSION.tgz
RUN cd Python-$PYTHON_VERSION && \
    ./configure --prefix=/usr/local/lib/python$PYTHON_VERSION/ --enable-ipv6 --enable-unicode=ucs4 --enable-shared && \
    make && make install

# Upgrade pip & install virtualenv
RUN pip install -U pip 'virtualenv<20'

# Create virtualenv
RUN virtualenv -p /usr/local/lib/python$PYTHON_VERSION/bin/python $CKAN_HOME

# Configure apache
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
COPY docker/webserver/apache/apache.wsgi $CKAN_CONFIG
COPY docker/webserver/apache/ckan.conf /etc/apache2/sites-enabled/
COPY docker/webserver/apache/wsgi.conf /etc/apache2/mods-available/
RUN a2enmod rewrite headers

# TODO dropping files in a volume is no good...
COPY docker/webserver/config/ckan_config.sh /usr/local/bin/

# Config CKAN app
COPY config/environments/$CKAN_ENV/production.ini $CKAN_CONFIG
COPY docker/webserver/entrypoint.sh /entrypoint.sh
RUN ln -s $CKAN_HOME/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini
RUN mkdir /var/tmp/ckan && chown www-data:www-data /var/tmp/ckan

# Install ckan app
COPY . /opt/catalog-app
WORKDIR /opt/catalog-app
RUN $CKAN_HOME/bin/pip install -r $REQUIREMENTS_FILE

# copy ckan script to /usr/bin/
COPY docker/webserver/common/usr/bin/ckan /usr/bin/ckan

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# apache
EXPOSE 80

# paster
EXPOSE 5000

CMD ["app","--wait-for-dependencies"]
