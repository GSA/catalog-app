.PHONY: all build test

all: build

build:
	docker-compose build

requirements:
	docker-compose run --rm app pip freeze > requirements-freeze.txt
test:
	docker-compose -f docker-compose.yml -f docker-compose.test.yml build
	docker-compose -f docker-compose.yml -f docker-compose.test.yml up test
