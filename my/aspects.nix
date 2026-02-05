# Objective: Define my.aspects option structure for organizing features into aspects
#
# Aspects are groups of features that can be enabled on hosts.
# Each aspect can contain:
# - Metadata: description, dependencies, features list
# - Module configurations: nixos, home-manager, nix-darwin
#
# Aspect values are set by files in the aspects/ folder.
{lib, ...}: {
  options.my.aspects = lib.mkOption {
    description = ''
      Available aspects that can be enabled on hosts.

      Aspects are groups of features organized by objectives rather than technical categories.
      Each aspect contains nixos, home-manager, and nix-darwin module definitions.

      Aspects are defined in the aspects/ folder following the convention:
      - aspects/ASPECT_NAME.nix - Metadata (description, dependencies)
      - aspects/ASPECT_NAME/FEATURE_NAME.nix - Feature implementations
    '';
    default = {};
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        description = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Human-readable description of this aspect";
        };

        dependsOn = lib.mkOption {
          type = lib.types.listOf lib.types.attrs;
          default = [];
          description = "Other aspects this aspect depends on";
        };

        features = lib.mkOption {
          type = lib.types.listOf (lib.types.listOf lib.types.str);
          default = [];
          description = ''
            List of features provided by this aspect.
            Each feature is a pair: [scope description]
            where scope is one of: "common", "nixos", "macos"
          '';
        };

        nixos = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = "NixOS module for this aspect";
        };

        home = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = "Shared Home Manager module for this aspect";
        };

        homeNixos = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = ''
            NixOS-only Home Manager module for this aspect

            Useful when a conditional OS-specific import is involved.
            (Conditional imports often leads to infinite recursion when done naively).
            Consider put small OS-specific adjustments in `home`
            and use this options for OS-specific concerns.
          '';
        };

        homeDarwin = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = ''
            macOS-only Home Manager module for this aspect

            Useful when a conditional OS-specific import is involved.
            (Conditional imports often leads to infinite recursion when done naively).
            Consider put small OS-specific adjustments in `home`
            and use this options for OS-specific concerns.
          '';
        };

        darwin = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = "nix-darwin module for this aspect";
        };
      };
    });
  };
}
