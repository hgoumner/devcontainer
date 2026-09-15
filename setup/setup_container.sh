#!/bin/bash
set -e

# 1. Start the container, keeping it alive with a no-op foreground process,
#    without touching the image's own ENTRYPOINT
podman run -d \
  --name "${CONTAINER_NAME}" \
  --hostname "${CONTAINER_NAME}" \
  --publish "${SSH_PORT}:22" \
  --volume /Users/jf82788/Repositories:/home/${USERNAME_CONTAINER}/Repositories \
  --volume /Users/jf82788/Downloads:/home/${USERNAME_CONTAINER}/Downloads \
  "${CONTAINER_NAME}:${TARGETPLATFORM}"

echo "Container started, running setup steps..."

echo "Copy over public ssh key..."
ssh-keygen -R "${SSH_PORT}"
podman cp ~/.ssh/devc.pub "${CONTAINER_NAME}":/home/${USERNAME_CONTAINER}/.ssh/authorized_keys
podman cp ~/.ssh/id_ed25519 "${CONTAINER_NAME}":/home/${USERNAME_CONTAINER}/.ssh/
podman cp ~/.ssh/id_ed25519.pub "${CONTAINER_NAME}":/home/${USERNAME_CONTAINER}/.ssh/

echo "Configure PATH for all SSH sessions (via /etc/environment, read by PAM)..."
podman exec --user root "${CONTAINER_NAME}" bash -c \
  "echo 'PATH=\"/home/${USERNAME_CONTAINER}/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"' >> /etc/environment"

echo "Configure zsh to source Nix profile for every session (via /etc/zsh/zshenv)..."
podman exec --user root "${CONTAINER_NAME}" bash -c \
  "echo '. /home/${USERNAME_CONTAINER}/.nix-profile/etc/profile.d/nix.sh' >> /etc/zsh/zshenv"

echo "Stow zsh config..."
podman exec --user ${USERNAME_CONTAINER} -w "/home/${USERNAME_CONTAINER}/config_repo" "${CONTAINER_NAME}" \
  stow --restow zsh starship yazi lla lsd git fzf lazygit lazynvim uv python pip

echo "Sanity-check zshenv/zshrc source without errors..."
podman exec --user ${USERNAME_CONTAINER} "${CONTAINER_NAME}" zsh -c \
  'source "$HOME/.zshenv" && source "$ZDOTDIR/.zshrc"' ||
  echo "warning: sourcing raised an error, continuing anyway"

echo "Load yazi plugins..."
podman cp ./yazi_packages.sh ${CONTAINER_NAME}:/home/${USERNAME_CONTAINER}
podman exec --user ${USERNAME_CONTAINER} "${CONTAINER_NAME}" bash -c "bash /home/${USERNAME_CONTAINER}/yazi_packages.sh"

# echo "Copy or install additional files/apps in the container..."

echo "Basic setup done..."
echo
