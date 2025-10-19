# Objective: This NixOS module sets up a comprehensive development environment shared across all machines, both macOS and NixOS.
{
  inputs,
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
          # I have to use nightly version because of vim.lsp.inline_completion
          # is not yet available in stable releases.
          inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
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

          # required by sidekick.nvim
          copilot-language-server
          lsof

          # When it makes sense, I prefer to keep language servers, linters and formatters
          # in projects' Nix devshells, but these ones are more convenient to have globally installed.
          #
          # Language Servers
          dockerfile-language-server
          gopls
          lua-language-server
          nixd
          pyright
          terraform-ls
          vscode-json-languageserver
          # and linters/formatters
          commitlint
          editorconfig-checker
          hadolint
          statix
        ]);

      home.file = {
        # Directory for installing NPM packages used by NeoVim plugins
        "${neovim-npm-dir}/.keep".text = "";

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
    # AI coding assistants
    #
    (let
      openspec = pkgs.buildNpmPackage rec {
        pname = "openspec";
        version = "0.12.0";

        src = pkgs.fetchFromGitHub {
          owner = "Fission-AI";
          repo = "OpenSpec";
          rev = "v${version}";
          hash = "sha256-wzdpcvdwzB47Oi/sQzxjgvMbF1RYaz8RyEvm8e6/K3g=";
        };

        pnpmDeps = pkgs.pnpm.fetchDeps {
          inherit pname version src;
          fetcherVersion = 2;
          hash = "sha256-J+Yc9qwS/+t32qqSywJaZwVuqoffeScOgFW6y6YUhIk=";
        };

        npmConfigHook = pkgs.pnpm.configHook;
        npmDeps = pnpmDeps;

        dontNpmPrune = true; # hangs forever on both Linux/darwin

        meta = with lib; {
          description = "Spec-driven development framework for AI coding assistants";
          homepage = "https://github.com/Fission-AI/OpenSpec";
          license = licenses.mit;
          mainProgram = "openspec";
          platforms = platforms.all;
        };
      };
    in {
      home.packages = [
        # Claude Code AI assistant
        inputs.nix-ai-tools.packages.${pkgs.system}.claude-code
        inputs.ccusage-rs.packages.${pkgs.system}.default

        # OpenCode AI assistant
        inputs.nix-ai-tools.packages.${pkgs.system}.opencode

        # GitHub Copilot CLI
        inputs.nix-ai-tools.packages.${pkgs.system}.copilot-cli

        # OpenSpec framework
        openspec
      ];

      home.file = {
        ".claude/commands".source = mkDotfilesLink config "claude/commands";
        ".claude/settings.json".source = mkDotfilesLink config "claude/settings.json";
        ".claude/CLAUDE.md".source = mkDotfilesLink config "claude/CLAUDE.md";
      };

      xdg.configFile."opencode".source = mkDotfilesLink config "opencode";
    })

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
      ];
    }

    #
    # TTS: MacOS has `say`, on linux I want a fallback
    #
    (lib.mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        espeak-ng
      ];

      programs.zsh.shellAliases.say = "espeak-ng";
    })
  ];
}
