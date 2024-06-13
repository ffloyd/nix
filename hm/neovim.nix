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
    pkgs.fd
    pkgs.ripgrep

    # globally installed language servers & formatters
    # (when possible I prefer keep them in projects' Nix devshells)
    pkgs.lua-language-server
    pkgs.stylua
  ];

  home.file = {
    ".config/nvim".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/nvim";
  };

  home.sessionVariables.EDITOR = "nvim";

  programs.git.extraConfig.core.editor = "nvim";

  programs.zsh.shellAliases = {
    vimdiff = "nvim -d";
    vi = "nvim";
    vim = "nvim";

    vi-config = "cd ${config.home.homeDirectory}/.config/nvim && nvim init.lua";
  };
}
