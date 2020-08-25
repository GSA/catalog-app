.PHONY: all build clean copy-src local requirements setup test up update-dependencies

CKAN_HOME := /usr/lib/ckan

all: build

build:
	docker-compose build

clean:
	docker-compose down -v --remove-orphans

copy-src:
	docker cp catalog-app_app_1:$(CKAN_HOME)/src .

local:
	docker-compose -f docker-compose.yml -f docker-compose.local.yml up

requirements:
	docker-compose run --rm -T app pip --quiet freeze > requirements-freeze.txt

test:
	docker-compose -f docker-compose.yml -f docker-compose.test.yml build
	docker-compose -f docker-compose.yml -f docker-compose.test.yml up --abort-on-container-exit test

update-dependencies:
	docker-compose run --rm -T app pip install -r requirements.txt

up:
	docker-compose up

harvest-gather-local:
	docker-compose -f docker-compose.yml \
		-f docker-compose.local.yml \
		exec app bash -c "source /usr/lib/ckan/bin/activate && \
			paster --plugin=ckanext-harvest harvester gather_consumer -c /etc/ckan/production.ini"

harvets-fetch-local:
	docker-compose -f docker-compose.yml \
		-f docker-compose.local.yml \
		exec app bash -c "source /usr/lib/ckan/bin/activate && \
			paster --plugin=ckanext-harvest harvester fetch_consumer -c /etc/ckan/production.ini"

harvest-run-local:
	docker-compose -f docker-compose.yml \
		-f docker-compose.local.yml \
		exec app ckan --plugin=ckanext-harvest harvester run
