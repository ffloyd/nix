{
  my.aspects.desktop = {
    features = [
      ["nixos" "Desktop apps and Flatpak packages"]
    ];

    nixos = {
      # to rule all my Mikrotik devices
      programs.winbox.enable = true;
    };

    homeNixos = {
      pkgs,
      pkgs-aot,
      ...
    }: {
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
  };
}
