{ pkgs ? import <nixpkgs> {} }:

pkgs.buildEnv {
  name = "dev-tools";
  paths = with pkgs; [
    neovim
    delta difftastic lazygit
    fd fzf ripgrep scooter
    atuin bat bottom duf dust jq jiq lla lsd ouch rich-cli rgx starship tabiew vivid zoxide
    yazi television
    gonzo hl-log-viewer less ov
    uv conda
  ];
}
