{
  inputs,
  config,
  ...
}: let
  inherit (config.my.helpers) mkOutOfStoreSymlink;
in {
  my.aspects.development = {
    features = [
      ["common" "Neovim setup and core dependencies"]
    ];

    home = {
      pkgs,
      lib,
      config,
      system,
      ...
    }: let
      neovim-npm-dir = ".neovim-npm";
      neovim-npm-dir-full = "${config.home.homeDirectory}/${neovim-npm-dir}";
      neovim-adjusted = pkgs.symlinkJoin {
        name = "neovim-adjusted";
        paths = [
          # I have to use nightly version because of vim.lsp.inline_completion
          # is not yet available in stable releases.
          inputs.neovim-nightly-overlay.packages.${system}.default
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
        ++ (with pkgs; [
          luajit
          fd
          ripgrep

          # optional by https://github.com/MagicDuck/grug-far.nvim
          ast-grep

          # required by snacks.nvim dashboard
          dwt1-shell-color-scripts

          # required by snacks.nvim image viewer
          imagemagick

          # required by sidekick.nvim
          copilot-language-server
          lsof
        ]);

      home.file = {
        # Directory for installing NPM packages used by NeoVim plugins
        "${neovim-npm-dir}/.keep".text = "";

        # Direct symlink to my actual NeoVim configuration
        ".config/nvim".source = mkOutOfStoreSymlink config "nvim";
      };

      home.sessionVariables.EDITOR = "nvim";
      programs.git.settings.core.editor = "nvim";

      programs.zsh.shellAliases = {
        vimdiff = "nvim -d";
        vi = "nvim";
        vim = "nvim";
      };
    };
  };
}
