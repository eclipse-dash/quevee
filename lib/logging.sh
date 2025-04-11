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

# Define log levels
LOG_LEVEL_ERROR=0
LOG_LEVEL_WARN=1
LOG_LEVEL_INFO=2
LOG_LEVEL_DEBUG=3

# ANSI color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

get_timestamp() {
    # shellcheck disable=SC2154
    if [[ "${LOG_TIMESTAMP}" == "on" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') "
    else
        echo ""
    fi
}

# Logging functions
log_error() {
    # shellcheck disable=SC2154
    if [[ ${CURRENT_LOG_LEVEL} -ge ${LOG_LEVEL_ERROR} ]]; then
        echo -e "${RED}[ERROR]${NC} $(get_timestamp)$*" >&2
    fi
}

log_warn() {
    if [[ ${CURRENT_LOG_LEVEL} -ge ${LOG_LEVEL_WARN} ]]; then
        echo -e "${YELLOW}[WARN]${NC}  $(get_timestamp)$*" >&2
    fi
}

log_info() {
    if [[ ${CURRENT_LOG_LEVEL} -ge ${LOG_LEVEL_INFO} ]]; then
        echo "[INFO]  $(get_timestamp)$*"
    fi
}

log_debug() {
    if [[ ${CURRENT_LOG_LEVEL} -ge ${LOG_LEVEL_DEBUG} ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $(get_timestamp)$*"
    fi
}
