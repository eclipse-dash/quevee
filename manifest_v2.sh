#!/bin/bash

# ********************************************************************************
#  Copyright (c) 2025 Contributors to the Eclipse Foundation
#
#  See the NOTICE file(s) distributed with this work for additional
#  information regarding copyright ownership.
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  SPDX-License-Identifier: Apache-2.0
# *******************************************************************************/

# This is an evolution of the initial manifest-toml.sh script; the main advancements is in the ability
# to process more complex input tuples (in addition to the artifact urls, we now get name, description
# and tags fields for an artifact), and to generate a correspondingly more structured json output file.
#
# This version is designed to be backwards compatible with the original script. When called with the same
# arguments as the first version, the behavior should be identical. To enable extended input and output
# processing, -x and -e command line switches are required.
# When using the extended output format, it is also highly recommended to set the package URL (PURL) type
# for the component that is being processed, so that an attempt can be made to build a valid PURL. E.g. for
# a Rust component, you should use --purl-type=cargo .
# Note: The PURL building feature might go horribly wrong for other tech ecosystems; it might be necessary
#       to pass the PURL as an input parameter / environment variable.

source lib/logging.sh
source lib/json.sh
source lib/toml.sh

CURRENT_LOG_LEVEL=${LOG_LEVEL:-${LOG_LEVEL_INFO}}
LOG_TIMESTAMP=${LOG_TIMESTAMP:-"off"}
INPUT_PURL_TYPE=${INPUT_PURL_TYPE:-"undefined"}
INPUT_EXTENDED_OUTPUT=${INPUT_EXTENDED_OUTPUT:-"false"}
INPUT_OUTPUT_JSON=${INPUT_OUTPUT_JSON:-"manifest.json"}
INPUT_OUTPUT_TOML=${INPUT_OUTPUT_TOML:-"manifest.toml"}

created=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
owner=$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f 1)
repo=$(echo "$GITHUB_REPOSITORY" | cut -d '/' -f 2)
if [ -n "$INPUT_RELEASE_URL" ]; then
    release_url="$INPUT_RELEASE_URL"
else
    release_url="unavailable"
fi

print_help() {
    echo "Utility that extracts software release quality artifact information from INPUT_ARTIFACTS_* environment variables and generates corresponding toml or json manifests"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -e                  Generate extended (json) output format instead of reduced toml"
    echo "  -j <file>           Set json manifest output file name (defaults to 'manifest.json')"
    echo "  -t <file>           Set toml manifest output file name (defaults to 'manifest.toml')"
    echo "  -v                  Increase logging verbosity"
    echo "  --help              Display this help message"
    echo "  --purl-type=<type>  PURL package type to use"
}

main() {
    # Parse command line arguments
    while getopts "ej:t:vx-:" opt; do
        case ${opt} in
        e)
            INPUT_EXTENDED_OUTPUT=true
            ;;
        j)
            INPUT_OUTPUT_JSON="${OPTARG}"
            ;;
        t)
            INPUT_OUTPUT_TOML="${OPTARG}"
            ;;
        v)
            ((CURRENT_LOG_LEVEL++))
            ;;
        -)
            case "${OPTARG}" in
            help)
                print_help
                exit 0
                ;;
            purl-type=*)
                INPUT_PURL_TYPE="${OPTARG#*=}"
                ;;
            *)
                echo "Invalid option: --${OPTARG}" >&2
                print_help
                exit 1
                ;;
            esac
            ;;
        *)
            print_help
            exit 1
            ;;
        esac
    done

    if [ "$INPUT_EXTENDED_OUTPUT" = "true" ]; then
        generate_json

        # Pass name of generated file as output
        echo "manifest_file=$INPUT_OUTPUT_JSON" >>$GITHUB_OUTPUT

    else
        generate_toml

        # Pass name of generated file as output
        echo "manifest_file=$INPUT_OUTPUT_TOML" >>$GITHUB_OUTPUT
    fi
}

generate_json() {
    # Check and warn about missing input data/env variables
    if [ "$INPUT_PURL_TYPE" = "undefined" ]; then
        log_warning "purl-type is not set, defaulting to 'undefined'"
    fi
    if [ -z "$GITHUB_REPOSITORY" ]; then
        log_error "GITHUB_REPOSITORY is not set, no repository to work with" >&2
        exit 1
    fi
    if ! env | grep -q "^INPUT_ARTIFACTS_"; then
        log_error "No INPUT_ARTIFACTS_ variables, no data to process" >&2
        exit 1
    fi

    # Prepare ouput component metadata
    purl_version=$(strip_tag_prefix "$GITHUB_REF_NAME")
    purl=$(generate_purl "$INPUT_PURL_TYPE" "$repo" "$purl_version")

    # Initialize INPUT_OUTPUT_JSON json with component release info
    init_json "$INPUT_OUTPUT_JSON" "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" "$created" "$GITHUB_ACTION" "$GITHUB_WORKFLOW_SHA" "$owner"
    add_component "$INPUT_OUTPUT_JSON" "$repo" "$GITHUB_REF_NAME" "$purl" "$release_url"

    # Process input artifacts
    for var in $(env | grep "^INPUT_" | cut -d= -f1); do
        value="${!var}"

        echo "$value" | while IFS='|' read -r url name description tags; do
            log_debug "Processing $url with description $description and tags: $tags"
            timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

            case "$var" in
            "INPUT_ARTIFACTS_DOCUMENTATION")
                log_debug "Adding documentation evidence"
                add_evidence "$INPUT_OUTPUT_JSON" "$repo" "$timestamp" "DOCUMENTATION" "$name" "$description" "$tags" "$url"
                ;;
            "INPUT_ARTIFACTS_LICENSE")
                log_debug "Adding licensing evidence"
                add_evidence "$INPUT_OUTPUT_JSON" "$repo" "$timestamp" "LICENSE" "$name" "$description" "$tags" "$url"
                ;;
            "INPUT_ARTIFACTS_README")
                log_debug "Adding readme evidence"
                add_evidence "$INPUT_OUTPUT_JSON" "$repo" "$timestamp" "README" "$name" "$description" "$tags" "$url"
                ;;
            "INPUT_ARTIFACTS_REQUIREMENTS")
                log_debug "Adding requirements evidence"
                add_evidence "$INPUT_OUTPUT_JSON" "$repo" "$timestamp" "REQUIREMENTS" "$name" "$description" "$tags" "$url"
                ;;
            "INPUT_ARTIFACTS_TESTING")
                log_debug "Adding testing evidence"
                add_evidence "$INPUT_OUTPUT_JSON" "$repo" "$timestamp" "TESTING" "$name" "$description" "$tags" "$url"
                ;;
            esac
        done
    done
}

generate_toml() {
    # Write header section
    generate_toml_header "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" "$created" "$GITHUB_ACTION" "$GITHUB_WORKFLOW_SHA" "$owner" "$repo" "$GITHUB_REF_NAME" "$release_url" >>"$INPUT_OUTPUT_TOML"

    # Write artifact sections
    for var in $(env | grep "^INPUT_" | cut -d= -f1); do
        value=$(extract_and_concatenate "$value")

        case "$var" in
        "INPUT_ARTIFACTS_DOCUMENTATION")
            generate_toml_section "documentation" "$value" >>"$INPUT_OUTPUT_TOML"
            ;;
        "INPUT_ARTIFACTS_LICENSE")
            generate_toml_section "licensing" "$value" >>"$INPUT_OUTPUT_TOML"
            ;;
        "INPUT_ARTIFACTS_README")
            generate_toml_section "readme" "$value" >>"$INPUT_OUTPUT_TOML"
            ;;
        "INPUT_ARTIFACTS_REQUIREMENTS")
            generate_toml_section "requirements" "$value" >>"$INPUT_OUTPUT_TOML"
            ;;
        "INPUT_ARTIFACTS_TESTING")
            generate_toml_section "testing" "$value" >>"$INPUT_OUTPUT_TOML"
            ;;
        esac
    done
}

# Validate URL using regex
validate_url() {
    local url="$1"
    local regex="^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(:[0-9]+)?(/[a-zA-Z0-9\-\._\?\,\'/\\\+&amp;%\$#\=~]*)?$"

    if [[ ! $url =~ $regex ]]; then
        log_error "Invalid URL: $url"
    fi
}

# Remove the initial 'v' from tag string, if it exists
strip_tag_prefix() {
    local tag="$1"
    local version="${tag#v}"
    echo "$version"
}

# Create a package url representation from type, component and version parameters
generate_purl() {
    local type="$1"
    local component="$2"
    local version="$3"
    echo "pkg:${type}/${component}@${version}"
}

# Legacy bridging code - extract artifact URLs from first parts of complex input strings
extract_and_concatenate() {
    local input="$1"
    local result=""

    # Process each line of the input
    while IFS= read -r line; do
        # Extract the first part of the line (up to the first '|')
        local first_part
        first_part=$(echo "$line" | cut -d '|' -f 1)

        # Append to the result, separated by commas
        if [ -n "$result" ]; then
            result="${result},${first_part}"
        else
            result="${first_part}"
        fi
    done <<<"$input"

    echo "$result"
}

main "$@"
