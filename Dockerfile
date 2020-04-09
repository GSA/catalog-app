FROM openknowledge/ckan-base:2.8

MAINTAINER Your Name Here <you@example.com>

# Set timezone
ARG TZ=UTC
RUN echo $TZ > /etc/timezone
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime

RUN apk add libffi-dev

COPY docker/ckan-entrypoint.d/* /docker-entrypoint.d/

RUN mkdir -p /var/lib/ckan/storage/uploads
RUN chown -R ckan:ckan /var/lib/ckan/storage

COPY requirements.txt .
RUN pip install -r requirements.txt
