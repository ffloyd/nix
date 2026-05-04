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

        email = lib.mkOption {
          type = lib.types.str;
          description = "Git email for this host";
        };

        gpgKey = lib.mkOption {
          type = lib.types.str;
          description = "GPG signing key for this host";
        };

        description = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Human-readable description of this host";
        };

        system = lib.mkOption {
          type = lib.types.enum ["x86_64-linux" "aarch64-darwin"];
          description = ''
            System architecture.

            Do not forget to update overview.nix when adding new options.";
          '';
        };

        aspects = lib.mkOption {
          type = lib.types.listOf (lib.types.enum (lib.attrNames config.my.aspects));
          default = [];
          description = ''
            Names of aspects to enable on this host.

            Use: aspects = ["base" "desktop"];
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
    inherit (lib.strings) join;
    inherit (inputs.nixpkgs.lib) nixosSystem;

    nixosHosts = filterAttrs (_: {system, ...}: hasSuffix "linux" system) config.my.hosts;
    darwinHosts = filterAttrs (_: {system, ...}: hasSuffix "darwin" system) config.my.hosts;

    getModsFromAspects = names: category:
      forEach names (name:
        config.my.aspects.${name}.${category} or {});

    # Assert that every aspect enabled on a host has its dependsOn satisfied.
    mkAspectAssertions = hostname: enabledAspectNames: {
      assertions = forEach enabledAspectNames (aspectName: let
        requiredAspectNames = config.my.aspects.${aspectName}.dependsOn or [];
        absentAspectNames =
          builtins.filter
          (requiredAspectName: !(builtins.elem requiredAspectName enabledAspectNames))
          requiredAspectNames;
        absentAspectsString = join ", " (map (n: "'${n}'") absentAspectNames);
      in {
        assertion = absentAspectNames == [];
        message =
          (
            if builtins.length absentAspectNames == 1
            then "${absentAspectsString} aspect is"
            else "${absentAspectsString} aspects are"
          )
          + " missing on host '${hostname}', but required by aspect '${aspectName}'!";
      });
    };

    mkNixosSystem = {
      hostname,
      username,
      email,
      gpgKey,
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
          inherit hostname username email gpgKey pkgs-aot system;
        };

        modules =
          (getModsFromAspects aspects "nixos")
          ++ [
            (mkAspectAssertions hostname aspects)
            {nixpkgs.config.allowUnfree = true;}
            nixos

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit hostname username email gpgKey system pkgs-aot;
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
      email,
      gpgKey,
      system,
      darwin,
      aspects,
      ...
    }: let
      pkgs-aot = inputs.nixpkgs-aot.legacyPackages.${system};
    in
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;

        specialArgs = {
          inherit hostname username email gpgKey system inputs pkgs-aot;
        };

        modules =
          (getModsFromAspects aspects "darwin")
          ++ [
            (mkAspectAssertions hostname aspects)
            {system.primaryUser = username;}
            darwin
          ];
      };

    mkHomeConfiguration = {
      username,
      email,
      gpgKey,
      system,
      home,
      aspects,
      ...
    }: let
      pkgs-aot = inputs.nixpkgs-aot.legacyPackages.${system};
    in
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        extraSpecialArgs = {
          inherit inputs username email gpgKey system pkgs-aot;
        };

        modules =
          [
            (mkAspectAssertions username aspects)
            home
          ]
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
