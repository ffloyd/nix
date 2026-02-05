# Objective: Define my.consts option as a loosely typed container for global constants
#
# Values are set by globals.nix and private.nix files at the top level.
# This allows centralizing all constants under the my.consts namespace while keeping
# sensitive data encrypted in a separate file.
{lib, ...}: {
  options.my.consts = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = ''
      Loosely typed attrset containing global constants shared across all modules.
    '';
  };
}
