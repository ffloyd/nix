# Objective: provide a desktop environment tailored for my workflows
{...}: {
  flake.nixosModules.desktop = {
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
          kdePackages.ksystemlog # System log viewer (but it works only for user-level logs atm)
          kdePackages.kjournald # Journal log viewer (simpler than ksystemlog)

          kdePackages.filelight # File light disk usage analyzer
          kdePackages.kompare # File/folder comparison tool
          kdePackages.krdc # Remote desktop client
          kdePackages.isoimagewriter # ISO image writer
          kdePackages.kgpg # GPG key management
          kdePackages.kleopatra # Certificate manager and GUI for GPG
          ktimetracker # Time tracking application

          # non-KDE apps, but useful in KDE
          wl-clipboard # Wayland clipboard CLI
          wayland-utils # Wayland utilities
          hardinfo2 # System profiler and benchmark tool
        ];

        home-manager.users.${username} = {
          services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
          services.kdeconnect.enable = true;
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
        # to rule all my Mikrotik devices
        programs.winbox.enable = true;

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
  };
}
