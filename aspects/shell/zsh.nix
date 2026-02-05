{config, ...}: let
  inherit (config.my.helpers) mkOutOfStoreSymlink;
in {
  my.aspects.shell = {
    features = [
      ["common" "Zsh shell"]
      ["common" "Fixed Home/End keybindings"]
      ["common" "Powerlevel10k theme"]
    ];

    nixos = {
      pkgs,
      username,
      ...
    }: {
      users.users.${username}.shell = pkgs.zsh;

      # Otherwise cannot use zsh as shell
      programs.zsh.enable = true;
    };

    darwin = {
      pkgs,
      username,
      ...
    }: {
      # Allow ZSH from Nix as a default shell
      environment.shells = [pkgs.zsh];
      users.users.${username}.shell = pkgs.zsh;

      programs.zsh = {
        # Create /etc/zshrc that loads the nix-darwin environment.
        enable = true;
        # Should be disabled to allow additional fpath modifications in user's config
        enableGlobalCompInit = false;
      };
    };

    home = {
      config,
      pkgs,
      ...
    }: {
      home.file.".p10k.zsh".source = mkOutOfStoreSymlink config "p10k.zsh";

      programs.zsh = {
        enable = true;

        autocd = true;
        autosuggestion.enable = true;
        enableVteIntegration = true;
        syntaxHighlighting.enable = true;

        initContent = ''
          # Home key - does not work by default
          bindkey '\e[H'  beginning-of-line
          bindkey '\eOH'  beginning-of-line

          # End key - does not work by default
          bindkey '\e[F'  end-of-line
          bindkey '\eOF'  end-of-line

          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';

        shellAliases = {
          p10k-reconfigure = "POWERLEVEL9K_CONFIG_FILE=~/.p10k.zsh p10k configure";
        };
      };
    };
  };
}
