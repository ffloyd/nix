{
  my.aspects.desktop = {
    features = [
      ["nixos" "Desktop apps and Flatpak packages"]
    ];

    nixos = {
      # to rule all my Mikrotik devices
      programs.winbox.enable = true;
    };

    homeNixos = {pkgs, ...}: {
      services.flatpak.packages = [
        # sometimes it has a big version lag on nixpkgs
        "io.anytype.anytype"

        # I had crashes with the nixpkgs version
        "me.proton.Mail"
      ];

      home.packages = [
        # Unofficial non-Electron Tidal client
        pkgs.tonearm

        pkgs.libreoffice

        pkgs.proton-pass
        pkgs.proton-vpn

        pkgs.telegram-desktop
        pkgs.signal-desktop

        pkgs.vlc

        pkgs.gimp-with-plugins
      ];
    };
  };
}
