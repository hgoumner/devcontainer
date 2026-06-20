## Core utils
# curl
# git
# make
# stow
# tar
# unzip
# wget

## git
# delta
# difftastic
# lazygit

## searching
# fd
# fzf
# igrep
# ripgrep

## Modern CLI replacements
# bat
# bottom
# jiq
# lla
# lsd
# starship
# tabiew
# zoxide

## File manager
# yazi

## logging
# gonzo

## Python
# uv
# uvx

{ pkgs ? import <nixpkgs> {} }:

pkgs.buildEnv {
  name = "dev-tools";
  paths = with pkgs; [
    curl gnumake gnutar stow unzip wget
    neovim
    git delta difftastic lazygit
    fd fzf igrep ripgrep 
    bat bottom duf dust jiq lla lsd starship tabiew zoxide
    yazi television
    gonzo
    uv
    zsh
    cargo rustc
    nodejs_26
    openssh
  ];
}
