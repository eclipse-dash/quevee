#!/bin/bash

# ********************************************************************************
#  Copyright (c) 2025 ETAS and others
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# https://www.eclipse.org/legal/epl-2.0.
#
#
# SPDX-License-Identifier: EPL-2.0

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

# Generate list of toml sections
generate_toml_section() {
    local section="$1"
    local entries="$2"
    local temp_output=""

    IFS=',' read -r -a array <<<"$entries"

    if [ ${#array[@]} -gt 0 ]; then
        for element in "${array[@]}"; do
            validate_url $element
	    url=$( get_url_from_filename $element )
            temp_output+=$'\n'"    \"$url\","
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

# Build external URL from file name
get_url_from_filename() {
    local filename=$1
    local regex="^http.*$"

    if [[ $filename =~ $regex ]]; then
        echo "$filename"
    else
	echo "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/${GITHUB_WORKFLOW_SHA}/${filename}"
    fi
}

### Main script section

OUTPUT="sdv-manifest.toml"

# Write header section
generate_toml_header >>"$OUTPUT"

# Write sections
for var in $(env | grep "^INPUT_" | cut -d= -f1); do
    value="${!var}"

    case "$var" in
    "INPUT_ARTEFACTS_REQUIREMENTS")
        generate_toml_section "requirements" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTEFACTS_TESTING")
        generate_toml_section "testing" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTEFACTS_DOCUMENTATION")
        generate_toml_section "documentation" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTEFACTS_CODING_GUIDELINES")
        generate_toml_section "coding_guidelines" "$value" >>"$OUTPUT"
        ;;
    "INPUT_ARTEFACTS_RELEASE_PROCESS")
        generate_toml_section "release_process" "$value" >>"$OUTPUT"
        ;;
    *)
        echo "Unknown artefact type ${var#INPUT_ARTEFACTS_}"
        ;;
    esac
done

# Pass name of generated file as output
echo "manifest_file=$OUTPUT" >>$GITHUB_OUTPUT
