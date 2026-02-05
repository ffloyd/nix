# nixosModules is declared by flake-parts built-in module.
# homeModules is declared by home-manager flake module.
# We only declare darwinModules here.
{
  lib,
  moduleLocation,
  ...
}: {
  options.flake = {
    darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      apply = lib.mapAttrs (k: v: {
        _class = "darwin";
        _file = "${toString moduleLocation}#darwinModules.${k}";
        imports = [v];
      });
      description = "Darwin modules that can be imported into darwinConfigurations";
    };
  };
}
