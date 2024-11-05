#!/bin/bash

time=$(date)
owner=$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f 1)
repo=$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f 2)
if [ -n "$INPUT_RELEASE_URL" ]; then
    release_url="$INPUT_RELEASE_URL"
else
    release_url="unavailable"
fi

generate_toml_header() {
    cat <<EOF
[metadata]
repo-url = "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
created = "$time"
by-action = "$GITHUB_ACTION"
project = "$owner"
repository = "$repo"
ref-tag = "$GITHUB_REF_NAME"
git-hash = "$GITHUB_WORKFLOW_SHA"
release-url = "$release_url"

EOF
}

# Generate artifact-list toml section
generate_toml_section() {
    local section="$1"
    local entries="$2"
    local temp_output=""

    IFS=',' read -r -a array <<<"$entries"

    if [ ${#array[@]} -gt 0 ]; then
        for element in "${array[@]}"; do
            validate_url $element
            temp_output+=$'\n'"    \"$element\","
        done

        cat <<EOF
$section = [$temp_output
]

EOF
    fi
}

# Validate URL using regex
validate_url() {
    local url="$1"
    local regex="^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(:[0-9]+)?(/[a-zA-Z0-9\-\._\?\,\'/\\\+&amp;%\$#\=~]*)?$"

    if [[ ! $url =~ $regex ]]; then
        echo "Invalid URL: $url" >&2
    fi
}

### Main script section

OUTPUT="manifest.toml"

# Write header section
generate_toml_header >>"$OUTPUT"

# Write artifact sections
for var in $(env | grep "^INPUT_" | cut -d= -f1); do
    value="${!var}"

    case "$var" in
    "INPUT_ARTIFACTS_DOCUMENTATION")
        generate_toml_section "documentation" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTIFACTS_LICENSE")
        generate_toml_section "licensing" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTIFACTS_README")
        generate_toml_section "readme" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTIFACTS_REQUIREMENTS")
        generate_toml_section "requirements" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTIFACTS_TESTING")
        generate_toml_section "testing" "$value" >>"$OUTPUT"
        ;;
    *)
        echo "Unknown artifact type ${var#INPUT_ARTIFACTS_}"
        ;;
    esac
done

# Pass name of generated file as output
echo "manifest_file=$OUTPUT" >>$GITHUB_OUTPUT
