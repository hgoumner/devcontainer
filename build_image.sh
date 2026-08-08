#!/usr/bin/bash

# Enable automatic export of all variables
set -a

# Source the .env file
source .env

# Disable automatic export
set +a

ARCHITECTURE=arm64

podman build --platform linux/${ARCHITECTURE} \
  --build-arg USERNAME_CONTAINER=${USERNAME_CONTAINER} \
  --build-arg USER_UID_CONTAINER=${USER_UID_CONTAINER} \
  -t devbox:${ARCHITECTURE} .
