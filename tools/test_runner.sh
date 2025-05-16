#!/bin/sh -l

# Copyright (C) 2024 ETAS 
# 
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0

export GITHUB_OUTPUT="sdv-manifest.toml"

export GITHUB_SERVER_URL=https://github.com
export GITHUB_REPOSITORY=eclipse-dash/quevee
export GITHUB_REF_NAME=main
export GITHUB_WORKFLOW_SHA=e69b6ff8f67e0d2edfd0968ebc5f99d7e8d763c7

export INPUT_ARTEFACTS_README="https://some.example.url,https://other.example.url"
export INPUT_ARTEFACTS_REQUIREMENTS="another/file.md,https://another.org/example-test/artefact.bz2"
export INPUT_ARTEFACTS_TESTING="http://first.doc.com/doc/url,https://another.doc.com/example/docs.zip"
export INPUT_ARTEFACTS_DOCUMENTATION="./Random/URL,https://another.org/example/artefact.bz2"
export INPUT_ARTEFACTS_CODING_GUIDELINES="./SomeOther/URL,https://another.org/example/artefact.bz2"
export INPUT_ARTEFACTS_RELEASE_PROCESS="./YetAnother/URL,https://another.org/example/artefact.bz2"

./sdv-manifest.sh
