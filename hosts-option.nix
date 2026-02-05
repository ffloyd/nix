# Objective: Define top-level hosts option for centralized host configuration
{lib, ...}: {
  options.hosts = lib.mkOption {
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

        system = lib.mkOption {
          type = lib.types.enum ["x86_64-linux" "aarch64-darwin"];
          description = "System architecture";
        };

        nixosModules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [];
          description = "NixOS modules for this host (only for *-linux systems)";
        };

        darwinModules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [];
          description = "nix-darwin modules for this host (only for *-darwin systems)";
        };

        homeModules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [];
          description = "Home Manager modules for this host";
        };
      };
    });
    default = {};
    description = "Host configurations indexed by alias";
  };
}
