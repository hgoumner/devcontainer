## Core utils
# curl
# gpg
# make
# stow
# tar
# unzip
# wget

## git
# delta
# difftastic
# git
# lazygit

## searching
# fd
# fzf
# ripgrep
# scooter

## Modern CLI replacements
# bat
# bottom
# duf
# dust
# jiq
# lla
# lsd
# starship
# tabiew
# zoxide

## File manager
# yazi
# television

## logging
# gonzo
# hl-log-viewer
# ov

## Python
# uv
# uvx

{ pkgs ? import <nixpkgs> {} }:

pkgs.buildEnv {
  name = "dev-tools";
  paths = with pkgs; [
    curl gnumake gnupg gnutar stow unzip wget
    neovim
    git delta difftastic lazygit
    fd fzf ripgrep scooter
    bat bottom duf dust jiq lla lsd starship tabiew zoxide
    yazi television
    gonzo hl-log-viewer ov
    uv
    zsh
    cargo rustc
    nodejs_26
    openssh
  ];
}
