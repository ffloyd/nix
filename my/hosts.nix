{
  inputs,
  lib,
  config,
  ...
}: {
  options.my.hosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "System hostname";
        };

        username = lib.mkOption {
          type = lib.types.str;
          description = "Primary user account name";
        };

        description = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Human-readable description of this host";
        };

        system = lib.mkOption {
          type = lib.types.enum ["x86_64-linux" "aarch64-darwin"];
          description = "System architecture";
        };

        aspects = lib.mkOption {
          type = lib.types.listOf lib.types.attrs;
          default = [];
          description = ''
            List of aspects to enable on this host.

            Aspects are references to config.my.aspects values.
            Use: aspects = with config.my.aspects; [ terminal desktop development ];
          '';
        };

        nixos = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = ''
            Host-specific NixOS module.

            Used for machine-specific configurations like hardware settings,
            bootloader config, and other NixOS-only options.
          '';
        };

        home = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = ''
            Host-specific Home Manager module.

            Used for user-specific configurations that don't fit into aspects,
            such as machine-specific home directory settings.
          '';
        };

        darwin = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = ''
            Host-specific nix-darwin module.

            Used for macOS-specific system configurations that don't fit into aspects.
          '';
        };

        adjustments = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = ''
            List of adjustments applied to this host.
          '';
        };
      };
    });
    default = {};
    description = ''
      Host configurations indexed by alias.

      Each host defines what machine it is (hostname, username, system)
      and what features it should have (aspects list).

      Machine-specific configurations are defined in the hosts/ folder:
      - hosts/HOST_ALIAS.nix - Host definition with aspect selection
      - hosts/HOST_ALIAS/ - Machine-specific modules (hardware, bootloader, etc.)
    '';
  };

  config = let
    inherit (lib) forEach hasSuffix;
    inherit (lib.attrsets) concatMapAttrs filterAttrs;
    inherit (inputs.nixpkgs.lib) nixosSystem;

    nixosHosts = filterAttrs (_: {system, ...}: hasSuffix "linux" system) config.my.hosts;
    darwinHosts = filterAttrs (_: {system, ...}: hasSuffix "darwin" system) config.my.hosts;

    getModsFromAspects = aspects: category: forEach aspects (aspect: aspect.${category} or {});

    mkNixosSystem = {
      hostname,
      username,
      system,
      nixos,
      home,
      aspects,
      ...
    }: let
      pkgs-aot = inputs.nixpkgs-aot.legacyPackages.${system};
    in
      nixosSystem {
        inherit system;

        specialArgs = {
          inherit hostname username pkgs-aot system;
        };

        modules =
          (getModsFromAspects aspects "nixos")
          ++ [
            {nixpkgs.config.allowUnfree = true;}
            nixos

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit hostname username system pkgs-aot;
              };

              home-manager.users.${username} = {
                imports =
                  [home]
                  ++ (getModsFromAspects aspects "home")
                  ++ (getModsFromAspects aspects "homeNixos");
              };
            }
          ];
      };

    mkDarwinSystem = {
      hostname,
      username,
      system,
      darwin,
      aspects,
      ...
    }:
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;

        specialArgs = {
          inherit hostname username system inputs;
          inherit (config) globals private;
        };

        modules =
          (getModsFromAspects aspects "darwin")
          ++ [
            {system.primaryUser = username;}
            darwin
          ];
      };

    mkHomeConfiguration = {
      username,
      system,
      home,
      aspects,
      ...
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        extraSpecialArgs = {
          inherit inputs username system;
          inherit (config) private;
        };

        modules =
          [home]
          ++ (getModsFromAspects aspects "home")
          ++ (getModsFromAspects aspects "homeDarwin");
      };
  in {
    flake.nixosConfigurations =
      concatMapAttrs
      (hostAlias: hostConfig: {
        ${hostConfig.hostname} = mkNixosSystem hostConfig;
      })
      nixosHosts;

    flake.darwinConfigurations =
      concatMapAttrs
      (hostAlias: hostConfig: {
        ${hostConfig.hostname} = mkDarwinSystem hostConfig;
      })
      darwinHosts;

    flake.homeConfigurations =
      concatMapAttrs
      (hostAlias: hostConfig: {
        ${hostConfig.username} = mkHomeConfiguration hostConfig;
      })
      darwinHosts;
  };
}
