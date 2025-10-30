# Objective: provide a desktop environment tailored for my workflows
{
  pkgs,
  pkgs-aot,
  username,
  ...
}: {
  imports = [
    #
    # Display manager configuration
    #
    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";
        extraPackages = with pkgs; [
          qt6.qtmultimedia # required for astronaut theme
        ];
      };
    }

    #
    # KDE Plasma configuration
    #
    {
      services = {
        desktopManager.plasma6.enable = true;
      };

      programs.kdeconnect.enable = true;
      programs.partition-manager.enable = true;

      environment.systemPackages = with pkgs; [
        kdePackages.kleopatra # GPG key manager

        # non-KDE apps, but useful in KDE
        wl-clipboard  # Wayland clipboard CLI
        wayland-utils # Wayland utilities
        hardinfo2     # System profiler and benchmark tool
      ];

      home-manager.users.${username} = {
        services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
      };
    }

    #
    # Create Windows installation USB drives
    #
    {
      home-manager.users.${username}.home.packages = with pkgs; [
        woeusb
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

          # I had crashes with the nixpkgs version
          "me.proton.Mail"
        ];

        home.packages = [
          # Unofficail non-Electron Tidal client
          pkgs-aot.high-tide

          pkgs.libreoffice

          pkgs.proton-pass
          pkgs.protonvpn-gui

          pkgs.telegram-desktop
          pkgs.discord

          pkgs.vlc
        ];
      };
    }
  ];
}
