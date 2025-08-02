{
  inputs,
  pkgs,
  config,
  username,
  mkDotfilesLink,
  ...
}: let
  gruvbox-gtk-theme = pkgs.gruvbox-gtk-theme.override {
    colorVariants = ["dark"];
    iconVariants = ["Dark"];
    sizeVariants = ["standard"];
    themeVariants = ["default" "orange"];
  };
in {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Hint Electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };

  services.greetd = {
    enable = true;
  };

  programs.regreet = {
    enable = true;
  };

  home-manager.sharedModules = [
    inputs.walker.homeManagerModules.default
  ];

  nix.settings = {
    substituters = [
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
    ];
    trusted-public-keys = [
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
    ];
  };

  home-manager.users.${username} = let
    hmConfig = config.home-manager.users.${username};
  in {
    # Hint Electron apps to use Wayland
    # (in addition to similar setting on NixOS config level)
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

    xdg.configFile."walker".source = mkDotfilesLink hmConfig "walker";
    xdg.configFile."hypr".source = mkDotfilesLink hmConfig "hypr";
    xdg.configFile."hyprpanel".source = mkDotfilesLink hmConfig "hyprpanel";
  };
}
