[![CircleCI](https://circleci.com/gh/GSA/catalog-app.svg?style=svg)](https://circleci.com/gh/GSA/catalog-app)

# catalog-app

Is a [Docker](http://docker.io)-based [CKAN](http://ckan.org) deployment. CKAN is used by Data.gov @ http://catalog.data.gov


## Development

### Requirements

We assume your environment is already setup with these tools.

- [Docker Engine](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/overview/)


### Setup

Build and start the docker containers.

    $ docker-compose up

Create an admin user.

    $ docker-compose run --rm app ckan sysadmin add admin

Open your web browser to [localhost:8080](http://localhost:8080/).


### Harvesters

To use CKAN's harvester you first need to create an "organization", once created click the "admin" button. You should now see "Harvest Sources" next to Datasets and Members. Click "Add Harvest Source", this CKAN already packages a number of harvesters ready to use include data.json and spatial harvesters.

For testing you can try out the data.json harvester by pointing it at any US Federal Agency Website adding /data.json. Example `http://gsa.gov/data.json` in the URL field.

Enter the URL to the appropriate endpoint to the "Source type" used, enter a title, select frequency of harvest (update interval), Set private or public and the organization. Click "Save"

>NOTE: The harvester won't do anything until you click "Reharvest" to start the harvester. Feel free to refresh the page periodically and watch the datasets get registered :)

Queue any scheduled harvest jobs.

    $ docker-compose run --rm app ckan harvest harvest_run

Start the gather consumer.

    $ docker-compose run --rm app ckan harvest gather-consumer

Start the fetch consumer.

    $ docker-compose run --rm app ckan harvest fetch-consumer

Mark any completed jobs as finished.

    $ docker-compose run --rm app ckan harvest harvest_run


#### fgdc2iso

TODO: complete this section.

For some harvest source types, you must have fgdc2iso properly configured with
a SaxonPE license. See the [GSA/datagov-deploy] and the Ansible vaullt.


### CKAN/catalog-app commands

These commands are run from within the `app` container with `docker-compose run`.

`ckan --plugin=ckanext-harvest harvester run`
>Start any pending harvesting jobs

`ckan --plugin=ckanext-geodatagov geodatagov harvest-job-cleanup`
>Harvest jobs can get stuck at Running state and stay that way forever. This will reset them and fix any harvest object issues they cause.

`ckan --plugin=ckanext-qa qa update_sel`
>Start QA analysis on all datasets whose 'last modified timestamp' is >= timestamp embedded in the following file: /var/log/qa-metadata-modified.log

`ckan --plugin=ckanext-qa qa collect-ids && ckan --plugin=ckanext-qa qa update`
>Compare to qa update_sel, this qa update will run analysis on ALL datasets. It will take loooooooong to finish.

`ckan --plugin=ckanext-geodatagov geodatagov clean-deleted`
>CKAN keeps deleted package in the DB. This clean command makes sure they are really gone.

`ckan tracking update`
>This needs to be run periodically in order to run analysis on raw data and generate summarized page view tracking data that ckan/solr can use.

`ckan --plugin=ckanext-report report generate`
>This generates /report/broken-links page showing broken link statistics for dataset resources by organization.

`ckan --plugin=ckanext-geodatagov geodatagov db_solr_sync`
>Over time solr can get out of sync from db due to all kind of glitches. This brings them back in sync.

`ckan --plugin=ckanext-spatial ckan-pycsw set_keywords -p` /etc/ckan/pycsw-collection.cfg
>This grabs top 20 tags from CKAN and put them into /etc/ckan/pycsw-collection.cfg as CSW service metadata keywords.

`ckan --plugin=ckanext-spatial ckan-pycsw set_keywords -p /etc/ckan/pycsw-all.cfg`
>This grabs top 20 tags from ckan and put them into /etc/ckan/pycsw-all.cfg as CSW service metadata keywords.

`ckan --plugin=ckanext-spatial ckan-pycsw load -p /etc/ckan/pycsw-all.cfg`
>Accesses CKAN api to load CKAN datasets into pycsw database.

`/usr/lib/ckan/bin/python /usr/lib/ckan/bin/pycsw-db-admin.py vacuumdb /etc/ckan/pycsw-all.cfg`
>Does vacuumdb job on pycsw database.

`/usr/lib/ckan/bin/python /usr/lib/ckan/bin/pycsw-db-admin.py reindex_fts /etc/ckan/pycsw-all.cfg`
>Rebuilds GIN index on pycsw records table to speed up full text search.

`ckan --plugin=ckanext-geodatagov geodatagov combine-feeds`
>This gathers 20 pages of CKAN feeds from /feeds/dataset.atom and generates /usasearch-custom-feed.xml to feed USAsearch. USAsearch uses Bing index as backend which does not understand pagination in atom feeds.

`ckan --plugin=ckanext-geodatagov geodatagov export-csv`
>This keeps records of all datasets that are tagged with Topic and Topic Categories, and generates /csv/topic_datasets.csv


### Source Code Folder (**src**):

Follow these steps only if your `src` folder is empty or you need the latest code

1. Start the app, from root folder.

    $ docker-compose up

1. Copy app source files to your local src folder.

    $ make copy-src

1. Stop the app: `docker-compose down`


### Workflow:

1. Start the app in local mode.

    $ make local

1. Make changes to the source code in `src`.
1. Restart apache to see your changes in action.

    $ docker-compose exec app service apache2 restart

1. Commit the changes, and push extensions to GitHub.
1. (optional) Pull in the latest dependencies, including nested dependencies.

    $ make update-dependencies

1. Update the pinned requirements in `requirements-freeze.txt`.

    $ make requirements

see: https://blog.engineyard.com/2014/composer-its-all-about-the-lock-file
the same concepts apply to pip.


## Tests

Tests are run from a special `test` docker container defined in
`docker-compose.test.yml`.

    $ make test


## Cloud.gov

Copy `vars.yml.template` to `vars.yml`, and customize the values in that file. Then, assuming you're logged in for the Cloud Foundry CLI:

Update and cache all the Python package requirements

```sh
./vendor_requirements.sh
```

Create the database used by CKAN itself. You have to wait a bit for
the datastore DB to be available. (See [the cloud.gov instructions on
how to know when it's
up](https://cloud.gov/docs/services/relational-database/#instance-creation-time).)

```sh
$ cf create-service aws-rds shared-psql ((app_name))-db
```

Create the Redis instance:

```sh
$ cf create-service redis32 standard-ha ((app_name))-redis
```

Ensure the catalog app can reach the Solr app.
```sh
$ cf add-network-policy ((app_name)) --destination-app ((app_name))-solr --protocol tcp --port 8983
```

## License and Contributing
We're so glad you're thinking about re-using and/or contributing to
Data.gov!

Before contributing to Data.gov we encourage you to read our [CONTRIBUTING](https://github.com/GSA/catalog-app/blob/master/CONTRIBUTING.md) guide, our [LICENSE](https://github.com/GSA/catalog-app/blob/master/LICENSE.md), and our README (you are here), all of which should be in this repository. If you have any questions, you can email the Data.gov team at [datagov@gsa.gov](mailto:datagov@gsa.gov).
