{inputs, config, ...}: let
  inherit (config.my.helpers) mkOutOfStoreSymlink;
in {
  my.aspects.desktop = {
    features = [
      ["nixos" "Niri WM"]
      ["nixos" "Noctalia Shell"]
    ];

    nixos = {pkgs, ...}: {
      programs.niri.enable = true;
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";

      environment.systemPackages = with pkgs; [
        # Niri dependencies
        xwayland-satellite

        # Noctalia & dependencies
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        playerctl
        brightnessctl
        imagemagick
        cliphist
        wlsunset

        # Noctalia theming
        nwg-look
        adw-gtk3
        qt6Packages.qt6ct

        # Required by Neovim to work with system clipboard
        wl-clipboard
      ];

      # required by Noctalia shell
      # see: https://docs.noctalia.dev/getting-started/nixos/
      networking.networkmanager.enable = true;
      hardware.bluetooth.enable = true;
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
    };

    homeNixos = {config, pkgs, ...}: {
      home.file.".config/niri/config.kdl".source = mkOutOfStoreSymlink config "niri/config.kdl";

      services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
    };
  };
}
