# Objective: Set nix package for Home Manager
{...}: let
  nixPackageModule = {pkgs, ...}: {
    # Otherwise it fails with error
    nix.package = pkgs.nix;
  };
in {
  hosts.macos-work.homeModules = [nixPackageModule];
}
