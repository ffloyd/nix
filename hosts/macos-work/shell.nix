# Objective: ZSH shell configuration
{...}: let
  shellModule = {
    pkgs,
    username,
    ...
  }: {
    # Allow ZSH from Nix as a default shell
    environment.shells = [pkgs.zsh];

    users.users.${username} = {
      # we need it to enable home-manager
      home = "/Users/${username}";
      shell = pkgs.zsh;
    };

    programs.zsh = {
      # Create /etc/zshrc that loads the nix-darwin environment.
      enable = true;
      # Should be disabled to allow additional fpath modifications in user's config
      enableGlobalCompInit = false;
    };
  };
in {
  hosts.macos-work.darwinModules = [shellModule];
}
