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
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
  lib.mkMerge [
    {
      home.packages = [
        # I do not use programs.neovim because I want to have directly
        # editable configuration files places out of the Nix
        # store. Unfortunately, programs.neovim unconditionally generates
        # immutable configuration files.
        pkgs.neovim-unwrapped
        pkgs.luajit
        pkgs.fd
        pkgs.ripgrep

        # optional by https://github.com/MagicDuck/grug-far.nvim
        pkgs.ast-grep

        # required by snacks.nvim dashboard
        pkgs.dwt1-shell-color-scripts

        # required by https://github.com/Robitx/gp.nvim
        (pkgs.sox.override {enableLame = true;})
        pkgs.curl

        # required by Copilot Chat
        pkgs.lynx
        pkgs.luajitPackages.tiktoken_core

        # globally installed language servers
        # (when possible I prefer keep them in projects' Nix devshells)
        pkgs.dockerfile-language-server-nodejs
        pkgs.gopls
        pkgs.lua-language-server
        pkgs.nixd
        pkgs.pyright
        pkgs.terraform-ls

        # globally installed formatters
        # (when possible I prefer keep them in projects' Nix devshells)
        pkgs.stylua
        pkgs.commitlint
        pkgs.editorconfig-checker
        pkgs.hadolint
        pkgs.statix
      ];

      home.file = {
        ".config/nvim".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/nvim";

        # required by https://github.com/zbirenbaum/copilot.lua
        ".copilot-node".source = "${pkgs.nodejs_20}/bin";
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
    (lib.mkIf pkgs.stdenv.isDarwin {
      home.packages = [
        # required by https://github.com/yetone/avante.nvim
        pkgs.pngpaste
      ];
    })
  ]
