# Integration with directly symlinked "dotfiles"
# (in contrast to generated config files in the Nix store)
{config, ...}: let
  inherit (config.my.helpers) mkOutOfStoreSymlink;
in {
  my.aspects.shell = {
    features = [
      ["common" "Custom Zsh functions from dotfiles"]
    ];

    home = {
      pkgs,
      lib,
      config,
      ...
    }: let
      functionsFilename = "zshrc.functions";
    in {
      # Separate file for custom zsh functions (direct symlink to dotfiles)
      home.file.".${functionsFilename}".source = mkOutOfStoreSymlink config functionsFilename;

      # packages needed for declared functions
      home.packages = with pkgs; [
        libnotify
      ];

      # source the file at the end of zsh init
      programs.zsh.initContent = lib.mkOrder 2000 ''
        source ~/.${functionsFilename}
      '';
    };
  };
}
