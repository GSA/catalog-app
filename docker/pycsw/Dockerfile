# Ubuntu 14.04 Trusty Tahyr
FROM ubuntu:trusty

# Install basic dependencies
RUN apt-get update -y && apt-get install -y \
    software-properties-common \
    python-software-properties \
    build-essential \
    python-dev \
    python-sqlalchemy \
    sqlite3 \
    libproj-dev \
    git \
    python-pip \
    libxml2-dev \
    libxslt1-dev \
    wget \
    zlib1g-dev \
    libgeos-dev \
    libgeos++-dev

# install PyCSW
ADD ./default.cfg /tmp/
ADD ./install_pycsw.sh /tmp/
RUN sh /tmp/install_pycsw.sh

EXPOSE 8000

# Output version.
CMD pip show pycsw
