.PHONY: all build clean copy-src local requirements setup test up update-dependencies

CKAN_HOME := /srv/app

all: build

build:
	docker-compose build

clean:
	docker-compose down -v --remove-orphans

copy-src:
	docker cp catalog-app_ckan_1:$(CKAN_HOME)/src .

local:
	docker-compose -f docker-compose.yml -f docker-compose.local.yml up

requirements:
	docker-compose run --rm -T ckan pip --quiet freeze > requirements-freeze.txt

test:
	docker-compose -f docker-compose.yml -f docker-compose.test.yml build
	docker-compose -f docker-compose.yml -f docker-compose.test.yml up test

update-dependencies:
	docker-compose run --rm -T ckan pip install -r requirements.txt

up:
	docker-compose up
