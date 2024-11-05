# Container image that runs your code
FROM alpine:3.10

# sh scripting is too painful
RUN apk add --no-cache bash

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY manifest-toml.sh /manifest-toml.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/manifest-toml.sh"]
