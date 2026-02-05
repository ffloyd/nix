# Machine-specific configuration for Framework 13 laptop (AMD AI-300 series)
#
# Objective: Centralize machine-specific configurations while keeping the rest of the config clean
# of device-specific workarounds.
{
  config,
  inputs,
  ...
}: let
  hostConfig = config.hosts.framework-13-amd-ai-300;
  pkgs-aot = inputs.nixpkgs-aot.legacyPackages.${hostConfig.system};
in {
  flake.nixosConfigurations.${hostConfig.hostname} = inputs.nixpkgs.lib.nixosSystem {
    inherit (hostConfig) system;

    specialArgs = {
      inherit (config) globals private;
      inherit inputs pkgs-aot;
      inherit (hostConfig) username hostname system;
      targetOS = "nixos";
    };

    modules =
      [
        {nixpkgs.config.allowUnfree = true;}

        # Common NixOS modules
        config.flake.nixosModules.base
        config.flake.nixosModules.desktop
        config.flake.nixosModules.browser
        config.flake.nixosModules.gaming
        config.flake.nixosModules.local-reverse-proxy
        config.flake.nixosModules.local-vtt-server
      ]
      # Host-specific modules (hardware + machine configs)
      ++ hostConfig.nixosModules
      ++ [
        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            inherit (config) private;
            inherit (hostConfig) username system;
          };

          home-manager.users.${hostConfig.username} = {
            imports =
              [
                config.flake.homeModules.terminal
                config.flake.homeModules.shell
                config.flake.homeModules.gpg
                config.flake.homeModules.development-environment
              ]
              ++ hostConfig.homeModules;
          };
        }
      ];
  };
}
