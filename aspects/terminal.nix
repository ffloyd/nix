{config, ...}: let
  inherit (config.my.helpers) mkOutOfStoreSymlink;
in {
  my.aspects.terminal = {
    description = "Terminal emulator configuration";

    home = {
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
      home.file.".config/kitty/kitty.conf".source = mkOutOfStoreSymlink config "kitty.conf";
    };
  };
}
