#
# Terminal Home Manager Module
#
{
  pkgs,
  lib,
  private,
  config,
  ...
}: let
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in {
  home.packages = with pkgs; [
    kitty
  ];

  home.file = {
    # To simplify tinkering with terminal configuration, we symlink the
    # configuration files directly to the files in the dotfiles
    # directory of this repository. (Instead of making them part of the
    # Nix store.)
    ".config/kitty/kitty.conf".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/kitty.conf";
  };

  programs.zsh.shellAliases = {
    # TODO: alias for kitty config?
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
}
