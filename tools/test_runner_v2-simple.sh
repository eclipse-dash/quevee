#!/bin/sh -l

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

export GITHUB_OUTPUT="manifest.toml"

export GITHUB_SERVER_URL=https://github.com
export GITHUB_REPOSITORY=eclipse-uprotocol/up-rust
export GITHUB_REF_NAME=v0.5.0
export GITHUB_ACTION=quevee_v2
export GITHUB_WORKFLOW_SHA=e69b6ff8f67e0d2edfd0968ebc5f99d7e8d763c7
export INPUT_RELEASE_URL=https://github.com/eclipse-uprotocol/up-rust/releases/tag/v0.5.0

export INPUT_ARTIFACTS_README="https://some.example.url,https://other.example.url"
export INPUT_ARTIFACTS_REQUIREMENTS="https://another.org/example/artifact.bz2"
export INPUT_ARTIFACTS_DOCUMENTATION="http://first.doc.com/doc/url,https://another.doc.com/example/docs.zip"

./manifest_v2.sh "$@"
