#
# NeoVim Home Manager module
#
{
  pkgs,
  lib,
  private,
  config,
  ...
}: let
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in {
  # I do not use programs.neovim because I want to have directly
  # editable configuration files places out of the Nix
  # store. Unfortunately, programs.neovim unconditionally generates
  # immutable configuration files.
  home.packages = [
    pkgs.neovim-unwrapped
  ];

  home.file = {
    ".config/nvim/init.lua".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/nvim/init.lua";
  };

  home.sessionVariables.EDITOR = "nvim";

  programs.git.extraConfig.core.editor = "nvim";

  programs.zsh.shellAliases = {
    vimdiff = "nvim -d";
    vi = "nvim";
    vim = "nvim";

    vi-config = "nvim ${config.home.homeDirectory}/.config/nvim/init.lua";
  };
}
