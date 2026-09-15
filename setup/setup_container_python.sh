#!/bin/bash

commands=(
"bash ~/Downloads/Miniforge3-Linux-aarch64.sh -b"
"mv ~/miniforge3/.condarc ~/miniforge3/.condarc.bak"
"cd ~/config_repo && stow uv python pip"
"uv python install 3.12"
"uv tool install ruff"
"uv tool install pylint"
"uv tool install basedpyright"
"ln -s ~/Downloads/jkit_0.8.0_linux_amd64/jkit ~/.local/bin"
)

for cmd in "${commands[@]}"; do
  podman exec --user ${USERNAME_CONTAINER} "${CONTAINER_NAME}" bash -c "$cmd"
done

