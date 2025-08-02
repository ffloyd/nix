{
  pkgs,
  lib,
  private,
  config,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  gruvbox-gtk-theme = pkgs.gruvbox-gtk-theme.override {
    colorVariants = ["dark"];
    iconVariants = ["Dark"];
    sizeVariants = ["standard"];
    themeVariants = ["default" "orange"];
  };
  mkDotfilesLink = path: mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/${path}";
in {
  # Hint Electron apps to use Wayland
  # (in addition to similar setting in NixOS module)
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Orange-Dark";
      package = gruvbox-gtk-theme;
    };
  };

  programs.hyprpanel = {
    enable = true;
  };

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  home.packages = [
    pkgs.wl-clipboard
    pkgs.hyprsunset
  ];

  # disable generation of a config file in order to use direct symlink
  xdg.configFile."walker/config.toml".enable = false;

  xdg.configFile."walker".source = mkDotfilesLink "walker";
  xdg.configFile."hypr".source = mkDotfilesLink "hypr";
  xdg.configFile."hyprpanel".source = mkDotfilesLink "hyprpanel";
}
