# Objective: This NixOS module sets up a comprehensive development environment shared across all machines, both macOS and NixOS.
{
  pkgs,
  lib,
  private,
  config,
  mkDotfilesLink,
  ...
}: {
  imports = [
    #
    # Core Git Setup
    #
    {
      programs.ssh.enable = true;

      programs.git = {
        enable = true;

        userName = private.fullName;
        userEmail = private.personalEmail;

        extraConfig = {
          push.autoSetupRemote = true;
          init.defaultBranch = "main";
          credential.helper = pkgs.lib.mkIf pkgs.stdenv.isDarwin "osxkeychain";
        };
      };
    }

    #
    # Git Commit Signing & Encryption (separate keys for work and personal)
    #
    {
      # Transparently encrypt files
      home.packages = with pkgs; [
        git-crypt
      ];

      programs.git = {
        signing = {
          key = private.personalGpgKey;
          signByDefault = true;
        };
      };
    }

    #
    # Use different git settings in work repositories
    #
    {
      programs.git = {
        includes = [
          {
            condition = "gitdir:~/Work/";
            contents = {
              user = {
                email = private.workEmail;
                signingkey = private.workGpgKey;
              };
              commit.gpgSign = true;
              tag.gpgSign = true;
              core.sshCommand = "ssh -i ~/.ssh/id_work";
            };
          }
        ];
      };
    }

    #
    # Fancy CLI git diffs with delta
    #
    {
      programs.git.delta = {
        enable = true;

        options = lib.mkMerge [
          {
            features = "decorations";
            side-by-side = true;
            relative-paths = true;
            line-numbers = false;
          }
          (lib.mkIf pkgs.stdenv.isDarwin
            {
              syntax-theme = "TwoDark";
            })
          (lib.mkIf pkgs.stdenv.isLinux
            {
              syntax-theme = "gruvbox-dark";
            })
        ];
      };
    }

    #
    # Neovim
    #
    (let
      neovim-npm-dir = ".neovim-npm";
      neovim-npm-dir-full = "${config.home.homeDirectory}/${neovim-npm-dir}";
      # Neovim with injected environment variables
      neovim-adjusted = pkgs.symlinkJoin {
        name = "neovim-adjusted";
        paths = [
          pkgs.neovim-unwrapped
        ];
        nativeBuildInputs = [
          pkgs.makeWrapper
        ];
        # Some NeoVim plugins require Node.js to be available in PATH,
        # but I don't want to install it globally.
        postBuild = ''
          wrapProgram $out/bin/nvim \
            --prefix PATH : ${lib.makeBinPath [pkgs.nodejs]} \
            --prefix PATH : "${neovim-npm-dir-full}/bin" \
            --set NPM_CONFIG_PREFIX "~/${neovim-npm-dir}"
        '';
      };
    in {
      home.packages =
        [
          # I do not use programs.neovim because I want to have directly
          # editable configuration files places out of the Nix
          # store. Unfortunately, programs.neovim unconditionally generates
          # immutable configuration files.
          neovim-adjusted
        ]
        # Binary dependencies for NeoVim and its plugins
        ++ (with pkgs; [
          luajit
          fd
          ripgrep
          (lib.mkIf stdenv.isLinux gcc)

          # optional by https://github.com/MagicDuck/grug-far.nvim
          ast-grep

          # required by snacks.nvim dashboard
          dwt1-shell-color-scripts

          # required by snacks.nvim image viewer
          imagemagick
        ]);

      home.file = {
        # Directory for installing NPM packages used by NeoVim plugins
        "${neovim-npm-dir}/.keep".text = "";

        # NeoVim's mcp-hub.nvim may complain that this directory is not exists
        ".mcp-hub/.keep".text = "";

        # Direct symlink to my actual NeoVim configuration
        ".config/nvim".source = mkDotfilesLink config "nvim";
      };

      home.sessionVariables.EDITOR = "nvim";
      programs.git.extraConfig.core.editor = "nvim";

      programs.zsh.shellAliases = {
        vimdiff = "nvim -d";
        vi = "nvim";
        vim = "nvim";
      };
    })

    #
    # Global Language Servers & Formatters
    #
    # When possible I prefer keep them in projects' Nix devshells,
    # but these ones are more convenient to have globally installed.
    {
      home.packages = with pkgs; [
        # Language Servers
        dockerfile-language-server-nodejs
        gopls
        lua-language-server
        nixd
        pyright
        terraform-ls

        # Formatters
        commitlint
        editorconfig-checker
        hadolint
        statix
      ];
    }

    #
    # Claude Code AI assistant
    #
    {
      home.packages = [
        pkgs.claude-code
      ];

      home.file = {
        ".claude/commands".source = mkDotfilesLink config "claude/commands";
        ".claude/settings.json".source = mkDotfilesLink config "claude/settings.json";
        ".claude/CLAUDE.md".source = mkDotfilesLink config "claude/CLAUDE.md";
      };
    }

    #
    # Nix Development Shells
    #
    {
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    }

    #
    # Docker
    #
    {
      home.packages = with pkgs; [
        colima # Docker Desktop is a paid service now, heh
        docker-client
      ];
    }

    #
    # Scripting Essentials
    #
    # Tools & helpers that I often use in bash scripts and one-liners
    {
      home.packages = with pkgs; [
        # data extraction & processing
        gawk
        jq
        wget

        # secrets management
        (pass.withExtensions (exts: [exts.pass-otp]))
        (lib.mkIf stdenv.isDarwin _1password-cli)

        # give CLI a voice
        espeak-ng
      ];
    }
  ];
}
