# Objective: Terminal
{config, ...}: let
  config' = config;
in {
  flake.homeModules.terminal = {
    pkgs,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      kitty
    ];

    # To simplify tinkering with terminal configuration, we symlink the
    # configuration files directly to the files in the dotfiles
    # directory of this repository. (Instead of making them part of the
    # Nix store.)
    home.file.".config/kitty/kitty.conf".source = config'.myLib.mkDotfilesLink config "kitty.conf";
  };
}
