{
  pkgs,
  lib,
  private,
  config,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  mkDotfilesLink = path: mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/${path}";
in {
  programs.hyprpanel = {
    enable = true;
  };

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  # disable generation of a config file in order to use direct symlink
  xdg.configFile."walker/config.toml".enable = false;

  xdg.configFile."walker".source = mkDotfilesLink "walker";
  xdg.configFile."hypr".source = mkDotfilesLink "hypr";
  xdg.configFile."hyprpanel".source = mkDotfilesLink "hyprpanel";
}
