# Objective: provide a desktop environment tailored for my workflows
{
  inputs,
  pkgs,
  config,
  username,
  mkDotfilesLink,
  mkEnvExports,
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

        # GreeterEnvironment sets variables for the display manager's greeter session (before user login)
        # XCURSOR_SIZE: Cursor size for X11/legacy cursor themes
        # HYPRCURSOR_SIZE: Cursor size for Hyprland's native Hyprcursor format
        # These must be set here because the greeter runs with its own environment,
        # separate from the user session, to ensure proper cursor sizing on HiDPI displays
        settings = {
          General = {
            GreeterEnvironment = "QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192,XCURSOR_SIZE=24,HYPRCURSOR_SIZE=24";
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

      xdg.portal.enable = true;

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

        # UWSM environment variables configuration
        # These variables are loaded by UWSM before starting Hyprland
        # https://wiki.hypr.land/Configuring/Environment-variables/
        xdg.configFile."uwsm/env".text = mkEnvExports {
          # Wayland Toolkit Backend Configuration
          # https://wiki.hypr.land/Configuring/Environment-variables/
          GDK_BACKEND = "wayland,x11"; # Forces GTK3/GTK4 apps to use Wayland backend with X11 fallback
          QT_QPA_PLATFORM = "wayland;xcb"; # Tells Qt apps to use Wayland backend with XCB (X11) fallback
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; # Disables client-side decorations on Qt apps (compositor handles them)

          # Wayland toolkit support for SDL and Clutter
          # https://wiki.archlinux.org/title/Wayland
          SDL_VIDEODRIVER = "wayland,x11,windows"; # Tells SDL2 apps to prefer Wayland, with fallback to X11 or Windows
          CLUTTER_BACKEND = "wayland"; # Forces Clutter toolkit apps to use Wayland backend

          # XDG variables (XDG_CURRENT_DESKTOP, XDG_SESSION_TYPE, XDG_SESSION_DESKTOP)
          # are automatically set by UWSM from the desktop entry's DesktopNames field
          # No need to set them explicitly here

          # Chromium and Electron apps Wayland support
          # NIXOS_OZONE_WL: NixOS-specific flag that adds --ozone-platform=wayland to wrapped apps
          # ELECTRON_OZONE_PLATFORM_HINT: Electron-native flag for Wayland platform detection
          # https://wiki.hypr.land/0.44.0/Nvidia/
          # https://github.com/NixOS/nixpkgs/pull/147557
          NIXOS_OZONE_WL = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";

          # Java applications fix for non-reparenting window managers
          # Prevents blank window issues with Java AWT/Swing applications
          # https://github.com/Smithay/smithay/issues/389
          _JAVA_AWT_WM_NONREPARENTING = "1";

          # Qt theming configuration
          # Allows consistent theming of Qt5/Qt6 applications using qt6ct
          # https://github.com/hyprwm/Hyprland/discussions/5030
          QT_QPA_PLATFORMTHEME = "qt6ct";

          # HiDPI display scaling for Qt applications
          # Set to 2 to match the internal monitor's scale factor
          # https://wiki.archlinux.org/title/HiDPI
          QT_AUTO_SCREEN_SCALE_FACTOR = "2";

          # UWSM application launcher systemd slices configuration
          # Organizes apps into: app-graphical (default), background-graphical (low priority), session-graphical (high priority)
          # https://github.com/Vladimir-csp/uwsm
          APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
        };
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
