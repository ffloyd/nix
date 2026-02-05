# Objective: Hardware-specific software packages
{...}: let
  packagesModule = {
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username}.home.packages = with pkgs; [
      # AMD GPU monitoring tool
      nvtopPackages.amd

      # Wireless network monitoring tool
      wavemon
    ];
  };
in {
  hosts.framework-13-amd-ai-300.nixosModules = [packagesModule];
}
