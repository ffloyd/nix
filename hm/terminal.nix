#
# Terminal Home Manager Module
#
# It responsible for setting up a terminal app and a terminal
# multiplexer.
{
  pkgs,
  lib,
  private,
  config,
  ...
}: let
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  tmuxConfHomePath = ".config/tmux/tmux.conf";
  alacrittyConfHomePath = ".config/alacritty/alacritty.toml";
in {
  home.packages = with pkgs; [
    alacritty
    tmux
  ];

  home.file = {
    # To simplify tinkering with terminal configuration, we symlink the
    # configuration files directly to the files in the dotfiles
    # directory of this repository. (Instead of making them part of the
    # Nix store.)
    ${tmuxConfHomePath}.source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/tmux.conf";
    ${alacrittyConfHomePath}.source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/alacritty.toml";

    # It's not very reproducible but I want to use TPM for tmux
    # plugins. Unfortunately many tmux plugins in Nixpkgs are
    # significantly outdated. Also, I there is no TPM in Nixpkgs. But
    # I can still use Nix to install TPM.
    ".config/tmux/tpm".source = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "v3.1.0";
      sha256 = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
    };
  };

  programs.zsh.shellAliases = {
    tmux-config = "$EDITOR ~/${tmuxConfHomePath}";
    alacritty-config = "$EDITOR ~/${alacrittyConfHomePath}";
  };
}
