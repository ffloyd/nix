# This module configures OS-level Hyprland support
# and should be used with Home Manager module with the same name
{
  pkgs,
  config,
  ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };

  services.greetd = {
    enable = true;
  };

  programs.regreet = {
    enable = true;
  };
}
