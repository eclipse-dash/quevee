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

# Initialize an empty JSON structure
init_json() {
    local output="$1"
    local repo_url="$2"
    local created="$3"
    local by_action="$4"
    local git_hash="$5"
    local project="$6"

    # Initialize the JSON structure with the specified keys and an empty components array
    jq -n --arg repo_url "$repo_url" \
        --arg created "$created" \
        --arg by_action "$by_action" \
        --arg git_hash "$git_hash" \
        --arg project "$project" \
        '{
              "repo-url": $repo_url,
              "created": $created,
              "by-action": $by_action,
              "git-hash": $git_hash,
              "project": $project,
              "components": []
          }' >"$output"
}

# Add a component to the components array
add_component() {
    local output="$1"
    local name="$2"
    local version="$3"
    local purl="$4"
    local releaseUrl="$5"

    # Create a component with empty evidence array
    jq --arg name "$name" \
        --arg version "$version" \
        --arg purl "$purl" \
        --arg releaseUrl "$releaseUrl" \
        '.components += [{
       "name": $name,
       "tag": $version,
       "purl": $purl,
       "releaseUrl": $releaseUrl,
       "evidence": []
     }]' "$output" >tmp.json && mv tmp.json "$output"
}

# Add evidence to a component (by component name)
add_evidence() {
    local output="$1"
    local component_name="$2"
    local created="$3"
    local evidence_type="$4"
    local evidence_name="$5"
    local description="$6"
    local assertions="$7"
    local url="$8"

    # Find the component by name and add evidence to its array
    jq --arg name "$component_name" \
        --arg created "$created" \
        --arg type "$evidence_type" \
        --arg evname "$evidence_name" \
        --arg desc "$description" \
        --arg assertions "$assertions" \
        --arg url "$url" \
        '(.components[] | select(.name == $name) | .evidence) += [{
       "created": $created,
       "type": $type,
       "name": $evname,
       "description": $desc,
       "tsfAssertions": $assertions,
       "url": $url
     }]' "$output" >tmp.json && mv tmp.json "$output"
}
