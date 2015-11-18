# catalog-app
catalog.data.gov app

###Installation:
- run install.sh on a vm provisioned with catalog-deploy (this will install the latest version of the app)

###Docker:
- prerequisites: docker client, docker machine, docker compose (i.e: docker toolbox `https://www.docker.com/docker-toolbox`)
- run `docker-compose up` to spin up the catalog-app stack (catalog-solr, catalog-db, catalog-redis, catalog-app)
