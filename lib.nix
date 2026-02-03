# Custom helper functions for use across the flake
#
# These are passed to modules via specialArgs.
# They require nixpkgs.lib to be passed as argument.
lib: rec {
  # Waiting for nix to build for every change in dotfiles is annoying.
  # To opt-out of this, we can create direct symlinks to dotfiles bypassing the store.
  # The trick relies on home-manager's `mkOutOfStoreSymlink` function.
  mkDotfilesLink = hmConfig: path:
    hmConfig.lib.file.mkOutOfStoreSymlink "${hmConfig.home.homeDirectory}/nix/dotfiles/${path}";

  # Creates individual symlinks for each file in a directory.
  # Allows generated files (Nix store) and experimental files (dotfiles) to coexist.
  # Filters out .keep placeholder files used to make empty directories trackable in git.
  mkDotfilesDirectoryEntriesSymlinks = hmConfig: sourceDotfilesDir: targetPrefix: let
    entries = builtins.readDir ./dotfiles/${sourceDotfilesDir};
    mkSymlink = name: type:
      if type == "regular" && name != ".keep"
      then {"${targetPrefix}/${name}".source = mkDotfilesLink hmConfig "${sourceDotfilesDir}/${name}";}
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
}
