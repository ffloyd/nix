# Objective: enable flake-parts to define nix-darwin modules
{lib, ...}: {
  options.flake = {
    darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "Darwin modules that can be imported into darwinConfigurations";
    };
  };
}
