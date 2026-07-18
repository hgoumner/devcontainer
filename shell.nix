## Core utils
# curl
# gpg
# make
# stow
# tar
# unzip
# wget
# xclip
# xsel

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

# data
# duckdb

## Modern CLI replacements
# atuin
# bat
# bottom
# duf
# dust
# jiq
# lla
# lsd
# ouch
# rich-cli
# starship
# tabiew
# vivid
# zellij
# zoxide

## File manager
# yazi
# television

## logging
# gonzo
# hl-log-viewer
# less
# ov

## Python
# uv
# uvx

{ pkgs ? import <nixpkgs> {} }:

pkgs.buildEnv {
  name = "dev-tools";
  paths = with pkgs; [
    curl gnumake gnupg gnutar stow unzip wget xclip xsel
    neovim
    git delta difftastic lazygit
    fd fzf ripgrep scooter
    duckdb
    atuin bat bottom duf dust jiq lla lsd ouch rich-cli starship tabiew vivid zellij zoxide
    yazi television
    gonzo hl-log-viewer less ov
    uv
    zsh
    openssh
  ];
}
