{
  pkgs,
  lib,
  config,
  mkDotfilesLink,
  ...
}: {
  imports = [
    #
    # Core Zsh Setup
    #
    {
      programs.zsh = {
        enable = true;

        autocd = true;
        autosuggestion.enable = true;
        enableVteIntegration = true;
        syntaxHighlighting.enable = true;
      };
    }

    #
    # powerlevel10k shell theme
    #
    {
      home.file.".p10k.zsh".source = mkDotfilesLink config "p10k.zsh";

      programs.zsh = {
        initContent = ''
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';

        shellAliases = {
          p10k-reconfigure = "POWERLEVEL9K_CONFIG_FILE=~/.p10k.zsh p10k configure";
        };
      };
    }

    #
    # fzf - foundation of modern terminal usage
    #
    {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      stylix.targets.fzf.enable = true;
    })

    #
    # Better ls
    #
    {
      programs.eza = {
        enable = true;
        enableZshIntegration = true;
      };
    }

    #
    # Better top
    #
    {
      programs.btop.enable = true;
      programs.htop.enable = true;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      stylix.targets.btop.enable = true;
    })

    #
    # Better cat & man
    #
    {
      programs.bat = lib.mkMerge [
        {enable = true;}
        (lib.mkIf pkgs.stdenv.isDarwin {config.theme = "Nord";})
      ];

      home.packages = with pkgs.bat-extras; [
        batman
      ];

      programs.zsh.initContent = ''
        eval "$(batman --export-env)"
      '';
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      stylix.targets.bat.enable = true;
    })

    #
    # Better cd
    #
    {
      programs.z-lua = {
        enable = true;
        enableAliases = true;
        enableZshIntegration = true;
        options = ["enhanced" "once" "fzf"];
      };
    }

    #
    # File manager
    #
    {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        package = pkgs.yazi.override {
          # support for rar files
          _7zz = pkgs._7zz-rar;
        };
      };
    }

    #
    # zsh + workbrew (macOS only)
    #
    (lib.mkIf pkgs.stdenv.isDarwin {
      programs.zsh = {
        # we need -u to disable security check
        # that camplains about homebrew's `workbrew`
        # user being owner of completion-related brew files.
        completionInit = "autoload -U compinit && compinit -u";
        initContent = let
          zshConfigBeforeCompInit = lib.mkOrder 550 ''
            FPATH="$(/opt/workbrew/bin/brew --prefix)/share/zsh/site-functions:''${FPATH}"
          '';

          zshConfig = lib.mkOrder 1000 "eval \"$(/opt/workbrew/bin/brew shellenv)\"";
        in
          lib.mkMerge [zshConfigBeforeCompInit zshConfig];
      };
    })

    #
    # Keybindings adjustments
    #
    {
      programs.zsh.initContent = ''
        # Home key - does not work by default
        bindkey '\e[H'  beginning-of-line
        bindkey '\eOH'  beginning-of-line

        # End key - does not work by default
        bindkey '\e[F'  end-of-line
        bindkey '\eOF'  end-of-line
      '';
    }

    #
    # Separate file for custom zsh functions (direct symlink to dotfiles)
    #
    (let filename = "zshrc.functions"; in
      {
        home.file.".${filename}".source = mkDotfilesLink config filename;

        # source the file at the end of zsh init
        programs.zsh.initContent = lib.mkOrder 2000 ''
          source ~/.${filename}
        '';
      }
    )
  ];
}
