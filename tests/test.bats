#!/usr/bin/env bats

load test_helper

HOST="ckan"
PORT="5000"
CKAN_DB="ckan"
CKAN_USER_ADMIN="ckan_admin"

function wait_for_app () {
  # The app takes quite a while to startup (solr initialization and
  # migrations), close to a minute. Make sure to give it enough time before
  # starting the tests.
  echo "# - Waiting for $HOST:$PORT" >&3
  local retries=10
  while ! nc -z -w 30 "$HOST" "$PORT" ; do
    if [ "$retries" -le 0 ]; then
      return 1
    fi

    retries=$(( $retries - 1 ))
    sleep 5
  done
}

function test_view_login () {
  local url="http://$HOST:$PORT/user/login"
  # echo "#   - Testing view login at $url" >&3
  run curl --silent --fail $url
  [ "$status" -ne 22 ]
}

function test_login () {

  local url="http://$HOST:$PORT/login_generic?came_from=/user/logged_in"
  
  run curl --silent --fail $url \
    --compressed \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'Origin: http://$HOST:$PORT' \
    -H 'Referer: http://$HOST:$PORT/user/login' \
    --data 'login=ckan_admin&password=test1234' \
    --cookie-jar ./cookie-jar
  
  [ "$status" -ne 22 ]

}

function test_create_org () {
  
  run psql -h db -U postgres $CKAN_DB -c "select apikey from public.user where name='$CKAN_USER_ADMIN';"
  local api_key=$(echo ${lines[2]} | xargs)  # run fill $output with all response and $line with each response line
  
  # echo "Create ORG API KEY = $api_key" >&3
  
  run curl -X POST \
    http://$HOST:$PORT/api/3/action/organization_create \
    -H "Authorization: $api_key" \
    -H "cache-control: no-cache" \
    -d '{"description": "Test organization","title": "Test Organization '$RNDCODE'","approval_status": "approved","state": "active","name": "test-organization-'$RNDCODE'"}'

  # echo "Create ORG $output" >&3
  local success=$(echo $output | grep -o '"success": true')

  if [ "$success" = '"success": true' ]; then
    return 0;
  else
    echo "Failed to create org. API KEY $api_key. RND $RNDCODE OUTPUT: $output" >&3
    return 1;
  fi
}

function test_create_dataset () {
  
  run psql -h db -U postgres $CKAN_DB -c "select apikey from public.user where name='$CKAN_USER_ADMIN';"
  local api_key=$(echo ${lines[2]} | xargs)  # run fill $output with all response and $line with each response line
  # echo "Create dataset API KEY = $api_key" >&3
  
  run curl -X POST \
    http://$HOST:$PORT/api/3/action/package_create \
    -H "Authorization: $api_key" \
    -H 'cache-control: no-cache' \
    -H 'content-type: application/json' \
    -d '
        {
          "license_title": "License not specified",
          "maintainer": null,
          "relationships_as_object": [],
          "private": true,
          "maintainer_email": null,
          "num_tags": 1,
          "metadata_created": "2019-12-18T19:01:33.429530",
          "metadata_modified": "2019-12-18T19:02:54.841495",
          "author": null,
          "author_email": null,
          "state": "active",
          "version": null,
          "type": "dataset",
          "resources": [
            {
              "conformsTo": "",
              "cache_last_updated": null,
              "describedByType": "",
              "labels": {
                "accessURL new": "Access URL",
                "conformsTo": "Conforms To",
                "describedBy": "Described By",
                "describedByType": "Described By Type",
                "format": "Media Type",
                "formatReadable": "Format",
                "created": "Created"
              },
              "webstore_last_updated": null,
              "clear_upload": "",
              "state": "active",
              "size": null,
              "describedBy": "",
              "hash": "",
              "description": "",
              "format": "CSV",
              "mimetype_inner": null,
              "url_type": null,
              "formatReadable": "",
              "mimetype": null,
              "cache_url": null,
              "name": "Test Resource",
              "created": "2019-12-18T19:02:54.448285",
              "url": "https://www.bia.gov/tribal-leaders-csv",
              "upload": "",
              "webstore_url": null,
              "last_modified": null,
              "position": 0,
              "resource_type": "file"
            }
          ],
          "num_resources": 1,
          "tags": [
            {
              "vocabulary_id": null,
              "state": "active",
              "display_name": "test",
              "id": "65c76784-e271-4eb1-9778-a738622a1a3d",
              "name": "test"
            }
          ],
          "tag_string": "test",
          "groups": [],
          "license_id": "notspecified",
          "relationships_as_subject": [],
          "organization": "test-organization-'$RNDCODE'",
          "isopen": false,
          "url": null,
          "notes": "The description of the test dataset",
          "owner_org": "test-organization",
          "bureau_code": "010:00",
          "contact_email": "tester@fake.com",
          "contact_name": "Tester",
          "modified": "2019-12-18",
          "public_access_level": "public",
          "publisher": "Department of the Interior",
          "unique_id": "doi-'$RNDCODE'",
          "title": "Test Dataset '$RNDCODE'",
          "name": "test-dataset-'$RNDCODE'",
          "program_code": "010:001"
        }'

  # echo "Create DATASET $output" >&3
  local success=$(echo $output | grep -o '"success": true')

  if [ "$success" = '"success": true' ]; then
    return 0;
  else
    echo "Failed to create dataset. API KEY $api_key. RND: $RNDCODE OUTPUT: $output" >&3
    return 1;
  fi
}

function test_read_dataset () {
  
  local test_url="http://$HOST:$PORT/api/3/action/package_show?id=test-dataset-$RNDCODE"
  run curl --fail --location --request GET $test_url --cookie ./cookie-jar
  local dataset_success=$(echo $output | grep -o '"success": true')

  if [ "$dataset_success" = '"success": true' ]; then
    return 0;
  else
    echo "Failed to read dataset URL = $test_url" >&3
    return 1;
  fi
}

#checks that the google id is in the html response
function check_google_id () {
  google_id='google-analytics-fake-key-testing-87654321' #this is completely random. Set to "googleanalytics.ids" in production.ini file
  find_id=$(curl --silent --fail --request GET 'http://$HOST:$PORT' | grep -o "$google_id")

  if  [ "$find_id" = "$google_id" ]; then
    return 0;
  else
    return 1;
  fi
}

@test "CKAN container is up" {
  wait_for_app
}

@test "/user/login is up" {
  test_view_login
}

@test "Test admin login" {
  test_login
}

@test "User can create org" {
  test_create_org
}

@test "User can create dataset" {
  test_create_dataset
}

@test "data is accessible for user" {
  test_read_dataset
}

@test "data is inaccessible to public" {
  run curl --fail --location --request GET "http://$HOST:$PORT/api/3/action/package_show?id=test-dataset-$RNDCODE"
  # Validate output is 22, curl response for 403 (Forbidden)
  [ "$status" -eq 22 ]
}

@test "Website display is working" {
  local url="http://$HOST:$PORT/dataset/test-dataset-$RNDCODE"
  
  run curl --silent --fail "$url" --cookie ./cookie-jar
  if [ "$status" -eq 0 ]; then
    return 0;
  else
    echo "# Failed URL $url: $status" >&3
    return 1;
  fi
}

@test "Google Analytics ID present" {
  # check_google_id
  echo "# Skipping google analytics test" >&3
}
