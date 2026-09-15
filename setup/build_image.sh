#!/bin/bash

# Enable automatic export of all variables
set -a

# Source the .env file
source .env

# Disable automatic export
set +a

podman build --platform linux/${TARGETPLATFORM} \
  --build-arg USERNAME_CONTAINER=${USERNAME_CONTAINER} \
  --build-arg USER_UID_CONTAINER=${USER_UID_CONTAINER} \
  -t ${CONTAINER_NAME}:${TARGETPLATFORM} .
