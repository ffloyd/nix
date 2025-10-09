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
    {
      environment.systemPackages = with pkgs; [
        sddm-astronaut
        qt6.qtmultimedia # required for astronaut theme
      ];

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";

        settings = {
          General = {
            GreeterEnvironment = "QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192";
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

          # Audio control GUI
          pkgs.pavucontrol
          pkgs.helvum
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
    # Quickshell based shell/bar
    #
    {
      home-manager.sharedModules = [
        inputs.caelestia-shell.homeManagerModules.default
      ];

      home-manager.users.${username} = {
        programs.caelestia = {
          enable = true;

          cli = {
            enable = true;
          };

          settings = {
            general.apps = {
              terminal = ["kitty"];
            };

            paths.wallpaperDir = "$HOME/nix/nixos/desktop/";
          };
        };
      };
    }

    #
    # Warm display colors during dark time
    #
    {
      home-manager.users.${username} = {
        services.hyprsunset = {
          enable = true;
          settings = {
            profile = [
              {
                time = "7:30";
                identity = true;
              }
              {
                time = "21:00";
                temperature = 5000;
                gamma = 0.8;
              }
            ];
          };
        };

        programs.zsh.shellAliases = {
          hl-sunset-disable = "systemctl --user stop hyprsunset.service";
          hl-sunset-enable = "systemctl --user restart hyprsunset.service";
        };
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

          # Unofficail non-Electron Tidal client
          pkgs.high-tide

          pkgs.libreoffice

          pkgs.proton-pass
          pkgs.protonmail-desktop
          pkgs.protonvpn-gui

          pkgs.telegram-desktop
          pkgs.discord

          inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
        ];
      };
    }
  ];
}
