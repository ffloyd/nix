# Machine-specific configuration for work MacBook
#
# Objective: Centralize machine-specific nix-darwin and home-manager configurations
{
  config,
  inputs,
  ...
}: let
  lib' = import ../lib.nix inputs.nixpkgs.lib;
  hostConfig = config.hosts.macos-work;
in {
  # Darwin configuration
  flake.darwinConfigurations.${hostConfig.hostname} = inputs.nix-darwin.lib.darwinSystem {
    inherit (hostConfig) system;

    specialArgs = {
      inherit (config) globals private;
      inherit inputs;
      inherit (hostConfig) username;
    };

    modules =
      [
        config.flake.darwinModules.workbrew
        config.flake.darwinModules.local-reverse-proxy
      ]
      ++ hostConfig.darwinModules;
  };

  # Standalone Home Manager configuration
  flake.homeConfigurations.${hostConfig.username} = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit (hostConfig) system;
      config.allowUnfree = true;
    };

    extraSpecialArgs = {
      inherit inputs;
      inherit (config) private;
      inherit (hostConfig) username system;
      inherit (lib') mkDotfilesLink mkDotfilesDirectoryEntriesSymlinks mkEnvExports;
    };

    modules =
      [
        config.flake.homeModules.terminal
        config.flake.homeModules.shell
        config.flake.homeModules.gpg
        config.flake.homeModules.development-environment
      ]
      ++ hostConfig.homeModules;
  };
}
