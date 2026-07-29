#!/bin/bash
set -e

CONTAINER_NAME="devbox"
IMAGE="devbox:amd64"
SSH_PORT="2222"
USERNAME_CONTAINER="dev"

# 1. Start the container, keeping it alive with a no-op foreground process,
#    without touching the image's own ENTRYPOINT
podman run -d \
  --name "${CONTAINER_NAME}" \
  --hostname "${CONTAINER_NAME}" \
  --publish "${SSH_PORT}:22" \
  "${IMAGE}"

echo "Container started, running setup steps..."

echo "Copy over public ssh key..."
podman cp ~/.ssh/devc.pub "${CONTAINER_NAME}":/home/${USERNAME_CONTAINER}/.ssh/authorized_keys

echo "Configure PATH for all SSH sessions (via /etc/environment, read by PAM)..."
podman exec --user root "${CONTAINER_NAME}" bash -c \
  "echo 'PATH=\"/home/${USERNAME_CONTAINER}/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"' >> /etc/environment"

echo "Configure zsh to source Nix profile for every session (via /etc/zsh/zshenv)..."
podman exec --user root "${CONTAINER_NAME}" bash -c \
  "echo '. /home/${USERNAME_CONTAINER}/.nix-profile/etc/profile.d/nix.sh' >> /etc/zsh/zshenv"

echo "Stow zsh config..."
podman exec --user ${USERNAME_CONTAINER} -w "/home/${USERNAME_CONTAINER}/config_repo" "${CONTAINER_NAME}" \
  stow --restow zsh starship yazi lla lsd git fzf lazygit lazynvim

echo "Sanity-check zshenv/zshrc source without errors..."
podman exec --user ${USERNAME_CONTAINER} "${CONTAINER_NAME}" zsh -c \
  'source "$HOME/.zshenv" && source "$ZDOTDIR/.zshrc"' ||
  echo "warning: sourcing raised an error, continuing anyway"

echo "Load yazi plugins..."
podman cp /xps-other/devcontainer/yazi_packages.sh ${CONTAINER_NAME}:/home/${USERNAME_CONTAINER}
podman exec --user ${USERNAME_CONTAINER} "${CONTAINER_NAME}" bash -c "bash /home/${USERNAME_CONTAINER}/yazi_packages.sh"

echo "Setup done..."
echo
