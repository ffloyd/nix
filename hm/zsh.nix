{
  pkgs,
  lib,
  private,
  config,
  ...
}: let
  inherit (pkgs) stdenv;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  terminalColorCodes = {
    NOCOLOR = "\033[0m";
    RED = "\033[0;31m";
    GREEN = "\033[0;32m";
    ORANGE = "\033[0;33m";
    BLUE = "\033[0;34m";
    PURPLE = "\033[0;35m";
    CYAN = "\033[0;36m";
    LIGHTGRAY = "\033[0;37m";
    DARKGRAY = "\033[1;30m";
    LIGHTRED = "\033[1;31m";
    LIGHTGREEN = "\033[1;32m";
    YELLOW = "\033[1;33m";
    LIGHTBLUE = "\033[1;34m";
    LIGHTPURPLE = "\033[1;35m";
    LIGHTCYAN = "\033[1;36m";
    WHITE = "\033[1;37m";
  };
  customZshFunctionsFileName = "zshrc.functions";
in {
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "Nord";
  };

  programs.z-lua = {
    enable = true;
    enableAliases = true;
    enableZshIntegration = true;
    options = ["enhanced" "once" "fzf"];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = lib.mkMerge [
    {
      enable = true;

      autocd = true;
      autosuggestion.enable = true;
      enableVteIntegration = true;

      syntaxHighlighting.enable = true;

      localVariables =
        {
          PERSONAL_EMAIL = private.personalEmail;
          WORK_EMAIL = private.workEmail;
        }
        // terminalColorCodes;

      shellAliases = {
        p10k-reconfigure = "POWERLEVEL9K_CONFIG_FILE=~/nix/hm/zsh/p10k.zsh p10k configure";
      };

      initExtra = ''
        source ~/.${customZshFunctionsFileName}

        # keybinding adjustments
        # Home key - does not work by default
        bindkey '\e[H'  beginning-of-line
        bindkey '\eOH'  beginning-of-line
        # End key - does not work by default
        bindkey '\e[F'  end-of-line
        bindkey '\eOF'  end-of-line

        # use bat as a man pager
        MANPAGER="sh -c 'col -bx | bat -l man -p'"

        # powerlevel10k shell theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ${./zsh/p10k.zsh} ]] || source ${./zsh/p10k.zsh}
      '';
    }
    (lib.mkIf stdenv.isDarwin {
      # we need -u to disable security check that camplains about homebrew's `workbrew` user being owner of completion related brew files.
      completionInit = "autoload -U compinit && compinit -u";
      initExtraBeforeCompInit = ''
        FPATH="$(/opt/workbrew/bin/brew --prefix)/share/zsh/site-functions:''${FPATH}"
      '';
      initExtra = "eval \"$(/opt/workbrew/bin/brew shellenv)\"";
    })
  ];

  home.file = {
    ".${customZshFunctionsFileName}".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/${customZshFunctionsFileName}";
  };
}
