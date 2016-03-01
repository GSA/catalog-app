#!/bin/sh
set -e

CONFIG="${CKAN_CONFIG}/pycsw-all.cfg"

abort () {
  echo "$@" >&2
  exit 1
}

write_config () {
  sed -i "s\\database=\\$(link_pycsw_postgres_url)\\" $CONFIG
}

link_pycsw_postgres_url () {
  local user=$DB_ENV_POSTGRESQL_USER
  local pass=$DB_ENV_POSTGRESQL_PASS
  local db=$DB_ENV_POSTGRESQL_PYCSW_DB
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "database=postgresql://${user}:${pass}@${host}/${db}"
}

write_config
