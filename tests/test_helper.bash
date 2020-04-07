
# to create (just once) random org and datasets
if [ -z $RNDCODE ]; then
    export RNDCODE=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
fi

function ensure_datastore () {
    run psql -h db -U postgres -c "CREATE DATABASE datastore OWNER ckan;"
	run psql -h db -U postgres -c "CREATE USER datastore_ro WITH PASSWORD 'datastore';"
	run psql -h db -U postgres -d ckan -c "GRANT SELECT ON datastore TO datastore_ro;"
    return 0;
}
