#!/bin/bash

# set up machine
if ! pgrep -x 'vfkit' >/dev/null; then 
  podman machine init --cpus 4 --memory 10240 --disk-size 25 --provider applehv
fi
podman machine start && \
podman machine cp ~/devcontainer/Zscaler.pem podman-machine-default:/tmp/zscaler.pem && \
podman machine ssh "sudo cp /tmp/zscaler.pem /etc/pki/ca-trust/source/anchors/zscaler.crt" && \
podman machine ssh "sudo update-ca-trust" && \
podman machine stop && \
podman machine start

echo "Done setting up podman machine"

podman pull ghcr.io/hgoumner/${CONTAINER_NAME}:${TARGETPLATFORM}
