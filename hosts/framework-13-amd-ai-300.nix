# Machine-specific configuration for Framework 13 laptop (AMD AI-300 series)
#
# Objective: Centralize machine-specific configurations while keeping the rest of the config clean
# of device-specific workarounds.
{
  config,
  inputs,
  ...
}: let
  # Import data directly to avoid circular dependencies
  globals = import ../globals.nix;
  private = import ../private.nix;
  lib' = import ../lib.nix inputs.nixpkgs.lib;

  hostname = "framework-13-amd-ai-300";
  hostConfig = private.hosts.${hostname};
  username = hostConfig.username;
  system = "x86_64-linux";
  pkgs-aot = inputs.nixpkgs-aot.legacyPackages.${system};
in {
  flake.nixosConfigurations.${hostConfig.hostname} = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs globals private username hostname system pkgs-aot;
      inherit (lib') mkDotfilesLink mkDotfilesDirectoryEntriesSymlinks mkEnvExports;
    };

    modules = [
      # Nixpkgs configuration
      {nixpkgs.config.allowUnfree = true;}

      # Hardware
      ./framework-13-amd-ai-300/_hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series

      # NixOS modules
      config.flake.nixosModules.base
      config.flake.nixosModules.desktop
      config.flake.nixosModules.browser
      config.flake.nixosModules.gaming
      config.flake.nixosModules.local-reverse-proxy
      config.flake.nixosModules.local-vtt-server

      # Machine-specific configuration
      (import ./framework-13-amd-ai-300/_nixos.nix)

      # Home Manager integration
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs private username system;
          inherit (lib') mkDotfilesLink mkDotfilesDirectoryEntriesSymlinks mkEnvExports;
        };

        home-manager.users.${username} = {
          imports = [
            config.flake.homeModules.terminal
            config.flake.homeModules.shell
            config.flake.homeModules.gpg
            config.flake.homeModules.development-environment
          ];
        };
      }
    ];
  };
}
