# Objective: Enable Home Manager self-management
{...}: let
  homeManagerModule = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
in {
  hosts.macos-work.homeModules = [homeManagerModule];
}
