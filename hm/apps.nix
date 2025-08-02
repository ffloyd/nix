{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.anytype

    pkgs.proton-pass
    pkgs.protonmail-desktop
    pkgs.protonvpn-gui

    pkgs.telegram-desktop

    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
  ];
}
