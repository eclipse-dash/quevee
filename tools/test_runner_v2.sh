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

export GITHUB_OUTPUT

export GITHUB_SERVER_URL=https://github.com
export GITHUB_REPOSITORY=eclipse-uprotocol/up-rust
export GITHUB_REF_NAME=v0.5.0
export GITHUB_ACTION=quevee_v2
export GITHUB_WORKFLOW_SHA=e69b6ff8f67e0d2edfd0968ebc5f99d7e8d763c7
export INPUT_RELEASE_URL=https://github.com/eclipse-uprotocol/up-rust/releases/tag/v0.5.0

read -r -d '' INPUT_ARTIFACTS_README <<'EOF'
https://example.com/page1|Name1|Example page 1|tag1,tag2,tag3
https://example.com/page2|Name2|Example page 2|tag2,tag4
EOF
export INPUT_ARTIFACTS_README

read -r -d '' INPUT_ARTIFACTS_REQUIREMENTS <<'EOF'
https://requirements.com/page1|ReqName1|Req Example page 1|rtag1,rtag2,rtag3
https://requirements.com/page2|ReqName2|Req Example page 2|rtag2,rtag4
EOF
export INPUT_ARTIFACTS_REQUIREMENTS

./manifest_v2.sh --purl_type=cargo -x "$@"
