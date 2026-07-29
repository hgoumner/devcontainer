{ pkgs ? import <nixpkgs> {} }:

pkgs.buildEnv {
  name = "dev-tools";
  paths = with pkgs; [
    curl gnumake gnupg gnutar stow unzip wget
    neovim
    delta difftastic lazygit
    fd fzf ripgrep scooter
    atuin bat bottom duf dust jq jiq lla lsd ouch rich-cli starship tabiew vivid zoxide
    yazi television
    gonzo hl-log-viewer less ov
    uv conda
  ];
}
