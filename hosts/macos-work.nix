# Machine-specific configuration for work MacBook
#
# Objective: Centralize machine-specific nix-darwin and home-manager configurations
{
  config,
  inputs,
  ...
}: let
  # Import data directly to avoid circular dependencies
  globals = import ../globals.nix;
  private = import ../private.nix;
  lib' = import ../lib.nix inputs.nixpkgs.lib;

  hostname = "macos-work";
  hostConfig = private.hosts.${hostname};
  username = hostConfig.username;
  system = "aarch64-darwin";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in {
  # Darwin configuration
  flake.darwinConfigurations.${hostConfig.hostname} = inputs.nix-darwin.lib.darwinSystem {
    inherit system;

    specialArgs = {
      inherit inputs globals private username;
    };

    modules = [
      config.flake.darwinModules.workbrew
      config.flake.darwinModules.local-reverse-proxy

      # Machine-specific configuration
      (import ./macos-work/_nix-darwin.nix)
    ];
  };

  # Standalone Home Manager configuration
  flake.homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    extraSpecialArgs = {
      inherit inputs private username system;
      inherit (lib') mkDotfilesLink mkDotfilesDirectoryEntriesSymlinks mkEnvExports;
    };

    modules = [
      config.flake.homeModules.terminal
      config.flake.homeModules.shell
      config.flake.homeModules.gpg
      config.flake.homeModules.development-environment

      # Machine-specific configuration
      (import ./macos-work/_home-manager.nix)
    ];
  };
}
