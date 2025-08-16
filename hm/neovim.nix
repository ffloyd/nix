#
# NeoVim Home Manager module
#
{
  pkgs,
  lib,
  private,
  config,
  mkDotfilesLink,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  neovim-npm-dir = ".neovim-npm";
  neovim-npm-dir-full = "${config.home.homeDirectory}/${neovim-npm-dir}";
  neovim = pkgs.symlinkJoin {
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
        --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.nodejs]} \
        --prefix PATH : "${neovim-npm-dir-full}/bin" \
        --set NPM_CONFIG_PREFIX "~/${neovim-npm-dir}"
    '';
  };
in
  lib.mkMerge [
    {
      home.packages = [
        # I do not use programs.neovim because I want to have directly
        # editable configuration files places out of the Nix
        # store. Unfortunately, programs.neovim unconditionally generates
        # immutable configuration files.
        neovim
        pkgs.luajit
        pkgs.fd
        pkgs.ripgrep

        # optional by https://github.com/MagicDuck/grug-far.nvim
        pkgs.ast-grep

        # required by snacks.nvim dashboard
        pkgs.dwt1-shell-color-scripts

        # required by snacks.nvim image viewer
        pkgs.imagemagick

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
        pkgs.commitlint
        pkgs.editorconfig-checker
        pkgs.hadolint
        pkgs.statix
      ];

      home.file = {
        # Directory for NPM packages used by NeoVim plugins
        "${neovim-npm-dir}/.keep".text = "";

        # NeoVim's mcp-hub.nvim may complain that this directory is not exists
        ".mcp-hub/.keep".text = "";

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

    (lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [pkgs.gcc];
    })

    #
    # Claude Code setup
    #
    {
      home.packages = [
        pkgs.claude-code
      ];

      home.file = {
        ".claude/commands".source = mkDotfilesLink config "claude/commands";
        ".claude/settings.json".source = mkDotfilesLink config "claude/settings.json";
      };
    }
  ]
