# Objective: provide a desktop environment tailored for my workflows
{
  inputs,
  pkgs,
  config,
  username,
  mkDotfilesLink,
  ...
}: let
  hmConfig = config.home-manager.users.${username};
  background = ./desktop/bg.jpg;
in {
  imports = [
    #
    # Display manager configuration
    #
    inputs.sddm-sugar-candy-nix.nixosModules.default
    {
      nixpkgs = {
        overlays = [
          inputs.sddm-sugar-candy-nix.overlays.default
        ];
      };

      # TODO: fix small cursor size
      # TODO: fix silent fingerprint scanning
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        # package = pkgs.kdePackages.sddm; # qt6 sddm version

        sugarCandyNix = {
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
      };
    }

    #
    # Hyprland & Wayland configuration
    #
    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      environment.sessionVariables = {
        # Hint Electron apps to use Wayland
        NIXOS_OZONE_WL = "1";
        # Bigger cursor size for my hidpi displays
        XCURSOR_SIZE = "24";
        HYPRCURSOR_SIZE = "24";
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
      };

      home-manager.users.${username} = {
        # Essential Hyprland/Wayland packages
        home.packages = [
          pkgs.wl-clipboard
          pkgs.brightnessctl
          pkgs.playerctl
          pkgs.hyprsysteminfo
          pkgs.wev # Wayland event viewer

          # language server
          pkgs.hyprls

          # Screen sharing
          pkgs.gnome-network-displays

          # GUI system monitor
          pkgs.gnome-system-monitor
        ];

        xdg.configFile."hypr/hyprland.conf".source = mkDotfilesLink hmConfig "hyprland.conf";
      };
    }

    #
    # Qt theming
    #
    {
      stylix.targets.qt.enable = true;

      home-manager.users.${username} = {
        stylix.targets.qt.enable = true;
      };
    }

    #
    # GTK theming
    #
    {
      home-manager.users.${username} = {
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };

        gtk = {
          enable = true;
          gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
          gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
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
    # Keyring
    #
    # Some apps (like Anytype) require a keyring to store secrets
    {
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.sddm-greeter.enableGnomeKeyring = true;
      security.pam.services.sddm-autologin.enableGnomeKeyring = true;

      # An app to inspect keyring
      home-manager.users.${username}.home.packages = [pkgs.seahorse];
    }

    #
    # Wallpaper via Hyprpaper
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
    # App Launcher: Walker
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
    # Topbar & OSD: Hyprpanel
    #
    {
      home-manager.users.${username} = {
        programs.hyprpanel = {
          enable = true;
        };

        home.packages = [
          pkgs.hyprsunset
          pkgs.adwaita-icon-theme

          # for LLM usage statistics widget
          inputs.ccusage-rs.packages.${pkgs.system}.default
          pkgs.jq
        ];

        xdg.configFile."hyprpanel".source = mkDotfilesLink hmConfig "hyprpanel";
      };
    }

    #
    # Disk Control
    #
    {
      home-manager.users.${username}.home.packages = with pkgs; [
        gnome-disk-utility # to manage disks and partitions
        woeusb # to create Windows installation USB drives
      ];
    }

    #
    # Essential Apps
    #
    {
      home-manager.users.${username} = {
        services.flatpak.packages = [
          # sometimes it has a big version lag on nixpkgs
          "io.anytype.anytype"
        ];

        home.packages = [
          # kind of flatpack GUI
          pkgs.gnome-software

          pkgs.libreoffice

          pkgs.proton-pass
          pkgs.protonmail-desktop
          pkgs.protonvpn-gui

          pkgs.telegram-desktop

          inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
        ];
      };
    }
  ];
}
