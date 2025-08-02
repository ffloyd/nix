{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    pkgs.anytype

    pkgs.proton-pass
    pkgs.protonmail-desktop
    pkgs.protonvpn-gui

    pkgs.telegram-desktop
    pkgs.thunderbird

    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
  ];
}
