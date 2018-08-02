#!/bin/bash

# This script is run from the `test` container in docker-compose.test.yml

set -o errexit
set -o pipefail
set -o nounset

host="$APP_PORT_5000_TCP_ADDR"
port="$APP_PORT_5000_TCP_PORT"

function test_setup () {
  echo waiting for app to startup...
  while ! nc -w 1 -z "$host" "$port"; do
    sleep 1
  done
}

function test_http () {
  local url="$1"

  echo -n "HTTP test on $url..."
  curl --fail --silent "$url" > /dev/null
  echo pass
}

test_setup
test_http "$host:$port/dataset"
