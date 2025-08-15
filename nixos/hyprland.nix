{
  inputs,
  pkgs,
  lib,
  config,
  username,
  mkDotfilesLink,
  ...
}: let
  hmConfig = config.home-manager.users.${username};
  background = ./hyprland/bg.jpg;
in {
  imports = [
    #
    # Display manager configuration
    #
    {
      # TODO: fix small cursor size
      # TODO: fix silent fingerprint scanning
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        # package = pkgs.kdePackages.sddm; # qt6 sddm version
      };
    }

    #
    # Hyprland
    #
    {
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

      home-manager.users.${username} = {
        # Hint Electron apps to use Wayland
        # (in addition to similar setting on NixOS config level)
        home.sessionVariables.NIXOS_OZONE_WL = "1";

        # Essential Hyprland/Wayland packages
        home.packages = [
          pkgs.wl-clipboard
          pkgs.hyprsysteminfo

          # language server
          pkgs.hyprls
        ];

        xdg.configFile."hypr/hyprland.conf".source = mkDotfilesLink hmConfig "hyprland.conf";
      };
    }

    #
    # Hyprpaper
    #
    {
      home-manager.users.${username}.services.hyprpaper = {
        enable = true;
        settings = {
          # I do not need it while I have just one wallpaper for all workspaces
          ipc = "off";

          preload = ["${background}"];

          wallpaper = [
            " , ${background}"
          ];
        };
      };
    }

    #
    # Walker
    #
    {
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

      home-manager.users.${username} = {
        programs.walker = {
          enable = true;
          runAsService = true;
        };

        # disable generation of a config file in order to use direct symlink
        xdg.configFile."walker/config.toml".enable = false;

        xdg.configFile."walker".source = mkDotfilesLink hmConfig "walker";
      };
    }

    #
    # Theming
    #
    inputs.sddm-sugar-candy-nix.nixosModules.default
    {
      nixpkgs = {
        overlays = [
          inputs.sddm-sugar-candy-nix.overlays.default
        ];
      };

      services.displayManager.sddm.sugarCandyNix = {
        enable = true;

        # https://github.com/Zhaith-Izaliel/sddm-sugar-candy-nix?tab=readme-ov-file#configuration
        settings = {
          Background = background;
          Font = "Iosevka Nerd Font Propo";
          FontSize = "24";
          HaveFormBackground = true;
          PartialBlur = true;
          FormPosition = "left";
        };
      };

      home-manager.users.${username} = {
        gtk = {
          enable = true;
          theme = {
            name = "Gruvbox-Orange-Dark";
            package = pkgs.gruvbox-gtk-theme.override {
              colorVariants = ["dark"];
              iconVariants = ["Dark"];
              sizeVariants = ["standard"];
              themeVariants = ["default" "orange"];
            };
          };
        };
      };
    }

    #
    # PLAYGROUND
    #
    {
      home-manager.users.${username} = {
        programs.hyprpanel = {
          enable = true;
        };

        home.packages = [
          pkgs.hyprsunset
        ];

        xdg.configFile."hyprpanel".source = mkDotfilesLink hmConfig "hyprpanel";
      };
    }
  ];
}
