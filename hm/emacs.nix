{pkgs, ...}: let
  myEmacs =
    if pkgs.stdenv.isDarwin
    then pkgs.emacs29-macport
    else pkgs.emacs29;
  myEmacsPkgs = pkgs.emacsPackagesFor myEmacs;
  treesitGrammars = myEmacsPkgs.treesit-grammars.with-all-grammars;
  myEmacsWithPackages = myEmacsPkgs.emacsWithPackages (
    epkgs: [
      # this package includes native module that is precompiled in nixpkgs
      # compiling it manually will involve installation of gcc, make, cmake, etc
      # (I do not want them be globally accessible)
      epkgs.vterm

      # Let Nix compile all grammars definitions for Emacs
      treesitGrammars
    ]
  );
in {
  home.packages =
    [myEmacsWithPackages]
    ++ (with pkgs; [
      emacs-all-the-icons-fonts

      # Because emacs expects the dictionaries to be on the same directory as aspell, they won't be picked up.
      # To fix it the aspellWithDicts package installed with the dictionaries
      (aspellWithDicts (dicts: with dicts; [en en-computers en-science ru]))

      # tools
      ripgrep
      coreutils-prefixed

      # Language Servers (if package not listed here - it should be installed in project's nix shell)
      nixd
      gopls
      nodePackages.pyright
      terraform-ls
    ]);

  # On MacOS we need this to make grammars visible for Emacs
  home.file.".emacs.d/tree-sitter".source = "${treesitGrammars}/lib";

  # copilot.el requires npm in order to install helpers
  # so we provide an "Emacs-local" installation of Node.js 20
  home.file.".emacs.d/nodejs-bin".source = "${pkgs.nodejs_20}/bin";
}
