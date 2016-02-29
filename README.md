# catalog-app
Is a [Docker](http://docker.io)-based [CKAN](http://ckan.org) deployment. CKAN is used by Data.gov @ http://catalog.data.gov

**This repository is beta, and is under continuous development**

>NOTE: Instructions below use {{ example }} to denote where to replace content with your own.

## Installation:
The application is deployed using [docker-compose](https://docs.docker.com/compose/overview/), please follow the [official documentation to install and setup](https://docs.docker.com/compose/install/).

**System Requirements:**
>Docker needs access to a minimum of 2 CPU and 4 GB of Memory, if you are using [Docker Toolbox](https://www.docker.com/products/docker-toolbox) or [Docker Machine](https://docs.docker.com/machine/) you will need to first completely power down the [virtualbox](https://www.virtualbox.org/) image (not pause or suspend). Once this is done go to the images settings and under "Hardware" move the slider from 1 to 2 CPU. Failure to do this will cause docker to hang @ `[installing ca-certificates](https://github.com/GSA/catalog-app/issues/11)`.

### Quick Start
After docker-compose installs check to make sure docker daemon running: `sudo service docker status` if not `sudo service docker start`
```
git clone https://github.com/GSA/catalog-app
cd catalog-app
sudo docker-compose up
```
If you do not wish to run docker as root user (i.e. `sudo`), you can add your UNIX user to the docker with `sudo useradd -G {{user}} docker`

### catalog-app stack:
* solr
* postgres *(w postgis extension for spatial harvester)*
* redis
* catalogapp (CKAN)
  * harvester-fetch
  * harvester-gather
  * fgdc2iso
* [pyCSW *(in progress)*](http://pycsw.org)

### Getting Started
This first thing you will need to do is create a new CKAN sysadmin so you can create datasets/organizations:
`ckan sysadmin add {{ name }}` for example `docker exec -it {{ container }} /bin/bash` then `ckan sysadmin add admin` it should then prompt you to enter/confirm a new password. **You can now login to through your web browser where the site will likely be running @ http://localhost or http://127.0.0.1. At the very bottom of the site click 'login' and enter the newly minted credentials you just created!**

To use CKAN's harvester you first need to create an "organization", once created click the "admin" button. You should now see "Harvest Sources" next to Datasets and Members. Click "Add Harvest Source", this CKAN already packages a number of harvesters ready to use include data.json and spatial harvesters.

Currently supported harvest sources include:
* CKAN
* CSW Server
* Web Accessible Folder (WAF)
* Single spatial metadata document
* Geoportal Server
* Web Accessible Folder (WAF) Homogeneous Collection
* Z39.50
* ArcGIS REST API
* /data.json

For testing you can try out the data.json harvester by pointing it at any US Federal Agency Website adding /data.json. Example `http://gsa.gov/data.json` in the URL field.

Enter the URL to the appropriate endpoint to the "Source type" used, enter a title, select frequency of harvest (update interval), Set private or public and the organization. Click "Save"

>NOTE: The harvester won't do anything until you click "Reharvest" to start the harvester. Feel free to refresh the page periodically and watch the datasets get registered :)

>You can speed up the harvest process with this command `docker-compose scale harvester-fetch-consumer=3` which adds 3 new harvester containers to distribute the workload.


## Other Useful Commands
Once running you can use either/both [docker commands](https://docs.docker.com/engine/reference/commandline/cli/) or [docker-compose commands](https://docs.docker.com/compose/reference/) to manage running containers. This needs to be performed atleast once to create a CKAN sysadmin. *If you are running docker as root you may need to ADD `sudo` before these commands*

>NOTE: docker and docker-compose have different synthax for their commands - even though some commands do functionally the same thing. As a general rule use `--help` (ex. `docker --help` or `docker-compose --help` after any proposed command to see it's expected format.

>IMPORTANT:
* `docker` commands use "CONTAINERID" to target which container(s) to run the command to/on. Use `docker ps` to find "CONTAINERID"
* `docker-compose ` commands use "Name" of the application in the docker-compose.yml file in the root of this repository. So catalog-app === app

### Docker commands
>to enter into the container in interactive mode as root:

* `docker exec -it {{containerid}} /bin/bash`
  * use `exit` to exit container

>to run a one off command inside the container:

* `docker exec {{containerid}} {{command}}`

### Docker-compose commands
>to enter into the container in interactive mode as root:
* `docker-compose run app /bin/bash`

>to run a one off command inside the container:

* `docker-compose run app {{command}}`

## CKAN/catalog-app commands
**This commands are run from *within* the catalog-app container using either `docker exec it` or `docker-compose run` as described above**

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

`ckan --plugin=ckanext-spatial ckan-pycsw set_keywords -p` /etc/ckan/pycsw-collection.cfg*
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

## License and Contributing
We're so glad you're thinking about re-using and/or contributing to Data.gov!

Before contributing to Data.gov we encourage you to read our [CONTRIBUTING](https://github.com/GSA/catalog-app/blob/master/CONTRIBUTING.md) guide, our [LICENSE](https://github.com/GSA/catalog-app/blob/master/LICENSE.md), and our README (you are here), all of which should be in this repository. If you have any questions, you can email the Data.gov team at [datagov@gsa.gov](mailto:datagov@gsa.gov).
