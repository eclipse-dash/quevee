# Copyright (C) 2024 ETAS 
# 
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0

# Container image that runs your code
FROM alpine:3.10

# sh scripting is too painful
RUN apk add --no-cache bash

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY manifest-toml.sh /manifest-toml.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/manifest-toml.sh"]
