FROM openknowledge/ckan-base:2.8

MAINTAINER Your Name Here <you@example.com>

# Set timezone
ARG TZ=UTC
RUN echo $TZ > /etc/timezone
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime

COPY docker/ckan-entrypoint.d/* /docker-entrypoint.d/

# TODO start ainstalling reqs
# COPY requirements.txt .
# RUN pip install -r requirements.txt
