Current setup will build but container dependencies are not fine tuned.
May require restarting `app` until `solr` and/or `db` are reachable.
```
docker-compose build
docker-compose up
```

`db`  requires initialization:
These steps were derived from the ansible playbook available here:

https://github.com/GSA/datagov-deploy/tree/master/ansible/roles/software/catalog
1. Install POSTGIS
```
docker-compose run app psql -h db -d ckan -U ckan
  CREATE EXTENSION POSTGIS;
  ALTER VIEW geometry_columns OWNER TO ckan;
  ALTER TABLE spatial_ref_sys OWNER TO ckan;
```
2. Setup db for  ckan and ckan extensions
```
docker-compose run app ckan db init
docker-compose run app ckan --plugin=ckanext-ga-report initdb
docker-compose run app ckan --plugin=ckanext-archiver archiver init
docker-compose run app ckan --plugin=ckanext-qa qa init
```

Restart `app`, site should be available at localhost:5000.

3. Create superuser/admin account account
```
docker-compose run app ckan sysadmin add admin
```