{
  description = "Development tools for container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };
  in
  {
    packages.${system}.dev-tools = pkgs.buildEnv {
      name = "dev-tools";

      paths = with pkgs; [
        neovim

        delta
        difftastic
        lazygit

        fd
        fzf
        ripgrep
        scooter

        atuin
        bat
        bottom
        duf
        dust
        jq
        lla
        lsd
        ouch
        rich-cli
        rgx
        starship
        tabiew
        vivid
        zoxide

        yazi
        television

        uv
        zellij
      ];
    };
  };
}
