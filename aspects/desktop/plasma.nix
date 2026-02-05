{
  my.aspects.desktop = {
    features = [
      ["nixos" "KDE Plasma and system utilities"]
    ];

    nixos = {pkgs, ...}: {
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
    };

    homeNixos = {pkgs, ...}: {
      services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
      services.kdeconnect.enable = true;
    };
  };
}
