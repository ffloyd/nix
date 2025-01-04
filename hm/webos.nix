{pkgs, ...}: {
  home.packages = with pkgs; [
    ares-cli
  ];
}
