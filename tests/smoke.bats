@test "Test home page is served" {
    run curl -o /dev/null -L -s -w "%{http_code}\n" $TARGET_URL
    [ "$status" -eq 0 ]
    [ "$output" = "200" ]
}

@test "Test status API is functioning" {
    run curl -o /dev/null -L -s -w "%{http_code}\n" $TARGET_URL/api/3/action/status_show
    [ "$status" -eq 0 ]
    [ "$output" = "200" ]
}

@test "Test status API returns expected CKAN version 2.3" {
    run curl -L -s $TARGET_URL/api/3/action/status_show
    [ "$status" -eq 0 ]
    success=$(echo $output | jq -r .success)
    ckan_version=$(echo $output | jq -r .result.ckan_version)
    [ "$success" = "true" ]
    [ "$ckan_version" = "2.3" ]
}

@test "Test status API returns expected site title Data.gov" {
    run curl -L -s $TARGET_URL/api/3/action/status_show
    [ "$status" -eq 0 ]
    success=$(echo $output | jq -r .success)
    site_title=$(echo $output | jq -r .result.site_title)
    [ "$success" = "true" ]
    [ "$site_title" = "Data.gov" ]
}

@test "Test datagovtheme is loaded" {
    run curl -L -s $TARGET_URL/api/3/action/status_show
    [ "$status" -eq 0 ]
    success=$(echo $output | jq -r .success)
    datagovtheme=$(echo $output | jq -r '.result.extensions[] | select(.=="datagovtheme")')
    [ "$success" = "true" ]
    [ "$datagovtheme" = "datagovtheme" ]
}
