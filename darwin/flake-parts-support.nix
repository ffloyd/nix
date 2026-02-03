# Objective: Declare flake output options to allow merging across multiple modules
#
# Note: nixosModules is declared by flake-parts built-in module.
# Note: homeModules is declared by home-manager flake module.
# We only declare darwinModules here.
{
  lib,
  ...
}: {
  options.flake = {
    darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "Darwin modules that can be imported into darwinConfigurations";
    };
  };
}
