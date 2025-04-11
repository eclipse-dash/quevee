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

# Container image that runs your code
FROM alpine:3.21

# sh scripting is too painful
RUN apk add --no-cache bash

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY manifest-toml.sh /manifest-toml.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/manifest-toml.sh"]
