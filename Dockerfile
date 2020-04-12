FROM ubuntu:bionic

# Match the version of python on cloud.gov

ARG PYTHON_VERSION=2.7.17

ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_CONFIG /etc/ckan/
ENV CKAN_ENV docker

# Install required packages
RUN apt-get -q -y update && apt-get -q -y install \
  apache2 \
  atool \
  bison \
  build-essential \
  git \
  htop \
  lib32z1-dev \
  libgdbm-dev \
  libgeos-dev \
  libpq-dev \
  libreadline-dev \
  libssl-dev \
  libxml2-dev \
  libxslt1-dev \
  netcat \
  postgresql-client \
  swig \
  wget \
  xmlsec1

# Get custom python version for virtualenv
RUN wget -O- https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz | tar -zxv -C /tmp

RUN cd /tmp/Python-$PYTHON_VERSION && \
    ./configure \
        --prefix=/usr/local \
        --enable-ipv6 \
        --enable-unicode=ucs4 \
        --enable-shared \
        --with-ensurepip=install && \
    make && make install && \
    ldconfig

RUN /usr/local/bin/pip install -U pip  && \
    /usr/local/bin/pip install virtualenv

# Create virtualenv
RUN mkdir -p $CKAN_HOME && \
   /usr/local/bin/virtualenv -p /usr/local/bin/python $CKAN_HOME

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
RUN $CKAN_HOME/bin/pip install -r requirements.txt
RUN $CKAN_HOME/bin/pip list
RUN $CKAN_HOME/bin/pip freeze

# auth_tkt (and ckan) requires repoze.who 2.0. ckanext-saml, used for
# production requires repoze.who==1.0.18
# installing the one-off repoze.who will upgrade Paste if no version is
# specified. ckanext-geodatagov is not compatible with Paste>=2.0
RUN $CKAN_HOME/bin/pip install -U repoze.who==2.0 Paste==1.7.5.1

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
