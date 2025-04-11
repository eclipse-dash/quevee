#!/bin/sh -l

# Copyright (C) 2024 ETAS
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

export GITHUB_OUTPUT="manifest.toml"

export GITHUB_SERVER_URL=https://github.com
export GITHUB_REPOSITORY=eclipse-dash/quevee
export GITHUB_REF_NAME=main
export GITHUB_WORKFLOW_SHA=e69b6ff8f67e0d2edfd0968ebc5f99d7e8d763c7

export INPUT_ARTIFACTS_README="https://some.example.url,https://other.example.url"
export INPUT_ARTIFACTS_REQUIREMENTS="https://another.org/example/artifact.bz2"
export INPUT_ARTIFACTS_DOCUMENTATION="http://first.doc.com/doc/url,https://another.doc.com/example/docs.zip"

./manifest-toml.sh
