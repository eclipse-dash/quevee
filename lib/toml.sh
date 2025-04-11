#!/bin/bash

# Copyright (C) 2025 ETAS
#
# This program and the accompanying materials are made available under the
# terms of the Apache License, Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# SPDX-License-Identifier: Apache-2.0

# Generate toml file header
generate_toml_header() {
    local repo_url="$1"
    local created="$2"
    local by_action="$3"
    local git_hash="$4"
    local project="$5"
    local repository="$6"
    local ref_tag="$7"
    local release_url="$8"

    cat <<EOF
[metadata]
repo-url = "$repo_url"
created = "$created"
by-action = "$by_action"
project = "$project"
repository = "$repository"
ref-tag = "$ref_tag"
git-hash = "$git_hash"
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
            validate_url "$element"
            temp_output+=$'\n'"    \"$element\","
        done

        cat <<EOF
$section = [$temp_output
]

EOF
    fi
}
