#!/bin/sh -l

# Copyright (C) 2024 ETAS 
# 
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0

export GITHUB_OUTPUT="manifest.toml"

export GITHUB_SERVER_URL=https://github.com
export GITHUB_REPOSITORY=eclipse-dash/quevee
export GITHUB_REF_NAME=main
export GITHUB_WORKFLOW_SHA=e69b6ff8f67e0d2edfd0968ebc5f99d7e8d763c7

export INPUT_ARTIFACTS_README="https://some.example.url,https://other.example.url"
export INPUT_ARTIFACTS_REQUIREMENTS="./Another/URL,https://another.org/example/artifact.bz2"
export INPUT_ARTIFACTS_DOCUMENTATION="http://first.doc.com/doc/url,https://another.doc.com/example/docs.zip"

./manifest-toml.sh
