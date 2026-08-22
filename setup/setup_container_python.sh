#!/bin/bash

commands=(
"bash ~/Downloads/Miniforge3-Linux-aarch64.sh -b"
"mv ~/miniforge3/.condarc ~/miniforge3/.condarc.bak"
"cd ~/config_repo && stow uv python"
"uv python install 3.12"
"uv tool install ruff pylint basedpyright"
)

for cmd in "${commands[@]}"; do
  podman exec --user ${USERNAME_CONTAINER} "$cmd"
done

