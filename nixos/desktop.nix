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
        ];

        xdg.configFile."hypr/hyprland.conf".source = mkDotfilesLink hmConfig "hyprland.conf";
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
    # Theming
    #
    inputs.stylix.nixosModules.stylix
    inputs.sddm-sugar-candy-nix.nixosModules.default
    {
      nixpkgs = {
        overlays = [
          inputs.sddm-sugar-candy-nix.overlays.default
        ];
      };

      stylix = {
        enable = true;
        autoEnable = false;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        image = background;

        fonts = {
          monospace = {
            name = "IosevkaTerm Nerd Font Mono";
            package = pkgs.nerd-fonts.iosevka-term;
          };
          serif = {
            name = "Iosevka Nerd Font Propo";
            package = pkgs.nerd-fonts.iosevka;
          };
          sansSerif = config.stylix.fonts.serif;
          emoji = config.stylix.fonts.serif;
        };

        targets = {
          qt.enable = true;
        };
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
        stylix.targets = {
          btop.enable = true;
          qt.enable = true;
          yazi.enable = true;
          spotify-player.enable = true;

          zen-browser = {
            enable = true;
            profileNames = ["Default Profile"];
          };
        };

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
        home.packages = [
          pkgs.libreoffice

          pkgs.anytype

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
