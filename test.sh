#!/bin/bash

# This script is run from the `test` container in docker-compose.test.yml

set -o errexit
set -o pipefail
set -o nounset

host="app"
port="80"

function test_setup () {
  local retries=10
  while ! nc -w 60 -z "$host" "$port"; do
    if [ "$retries" -le 0 ]; then
      echo "app did not start" >&2
      return 1
    fi

    retries=$(( $retries - 1 ))
    sleep 5
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
