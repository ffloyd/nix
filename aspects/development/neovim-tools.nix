{
  my.aspects.development = {
    features = [
      ["common" "Language servers and formatters for Neovim"]
    ];

    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        # Language Servers
        dockerfile-language-server
        gopls
        lua-language-server
        nixd
        pyright
        terraform-ls
        vscode-json-languageserver

        # Linters/formatters
        commitlint
        editorconfig-checker
        hadolint
        statix
      ];
    };

    homeNixos = {pkgs, ...}: {
      home.packages = [pkgs.gcc];
    };
  };
}
