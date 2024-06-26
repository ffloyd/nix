{
  config,
  pkgs,
  private,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = private.darwinUsername;
  home.homeDirectory = "/Users/${private.darwinUsername}";

  imports = [
    ../hm/zsh.nix
    ../hm/terminal.nix
    ../hm/git.nix
    ../hm/emacs.nix
    ../hm/devtools.nix
    ../hm/gpg.nix
    ../hm/neovim.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [];

  programs.zsh = {
    shellAliases = {
      os-rebuild = "darwin-rebuild switch --flake ~/nix";
      hm-rebuild = "home-manager switch --flake ~/nix";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
