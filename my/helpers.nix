# Objective: provide global access to a collection of helper functions
{lib, ...}: {
  options.my.helpers = lib.mkOption {
    type = lib.types.attrs;
    description = ''
      Custom helper functions for this flake.

      Available helpers:
      - mkOutOfStoreSymlink - Create direct symlink to dotfiles bypassing Nix store
      - mkDotfilesDirectoryEntriesSymlinks - Create symlinks for all files in a directory
      - mkEnvExports - Convert attrset to shell export statements
    '';
  };

  config.my.helpers = rec {
    # Waiting for nix to build for every change in dotfiles is annoying.
    # To opt-out of this, we can create direct symlinks to dotfiles bypassing the store.
    # The trick relies on home-manager's `mkOutOfStoreSymlink` function.
    mkOutOfStoreSymlink = hmConfig: path:
      hmConfig.lib.file.mkOutOfStoreSymlink "${hmConfig.home.homeDirectory}/nix/dotfiles/${path}";

    # Creates individual symlinks for each file in a directory.
    # Allows generated files (Nix store) and experimental files (dotfiles) to coexist.
    # Filters out .keep placeholder files used to make empty directories trackable in git.
    mkDotfilesDirectoryEntriesSymlinks = hmConfig: sourceDotfilesDir: targetPrefix: let
      entries = builtins.readDir ../dotfiles/${sourceDotfilesDir};
      mkSymlink = name: type:
        if type == "regular" && name != ".keep"
        then {"${targetPrefix}/${name}".source = mkOutOfStoreSymlink hmConfig "${sourceDotfilesDir}/${name}";}
        else {};
    in
      lib.mkMerge (lib.mapAttrsToList mkSymlink entries);

    # Converts attribute set to shell export statements for environment configuration files.
    # Values are properly escaped for shell using escapeShellArg.
    mkEnvExports = envVars:
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList
        (name: value: "export ${name}=${lib.escapeShellArg value}")
        envVars
      );
  };
}
