#!/bin/env zsh

packages=(
  "AnirudhG07/plugins-yazi:copy-file-contents"
  "AnirudhG07/rich-preview"
  "Ape/simple-status"
  "h-hg/yamb"
  "malick-tammal/monokai"
  "yazi-rs/plugins:diff"
  "yazi-rs/plugins:git"
  "yazi-rs/plugins:jump-to-char"
  "yazi-rs/plugins:smart-enter"
  "yazi-rs/plugins:smart-filter"
  "yazi-rs/plugins:toggle-pane"
  "yazi-rs/plugins:types"
  "yazi-rs/plugins:vcs-files"
)

for pkg in "${packages[@]}"; do
  echo "Installing $pkg..."
  ya pkg add "$pkg"
done
