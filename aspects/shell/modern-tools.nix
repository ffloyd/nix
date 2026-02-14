{
  my.aspects.shell = {
    features = [
      ["common" "FZF integration"]
      ["common" "Eza (modern ls replacement)"]
      ["common" "Z-lua for smart directory jumping"]
      ["common" "Btop and htop (modern top replacements)"]
      ["common" "Bat (modern cat with syntax highlighting)"]
      ["common" "Batman (man pages with bat)"]
      ["common" "Yazi terminal file manager"]
    ];

    # I use stylix only on NixOS
    homeNixos = {
      stylix.targets = {
        fzf.enable = true;
        btop.enable = true;
        bat.enable = true;
        yazi.enable = true;
      };
    };

    home = {
      pkgs,
      lib,
      ...
    }: let
      inherit (lib) mkIf mkMerge;
      inherit (pkgs.stdenv) isDarwin;
    in {
      # Fuzzy finding for files, commands, and history
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      # Better ls
      programs.eza = {
        enable = true;
        enableZshIntegration = true;
      };

      # Better cd
      programs.z-lua = {
        enable = true;
        enableAliases = true;
        enableZshIntegration = true;
        options = ["enhanced" "once" "fzf"];
      };

      # Better top
      programs.btop.enable = true;

      programs.htop.enable = true;

      # Better cat & man
      programs.bat = mkMerge [
        {enable = true;}
        (mkIf isDarwin {config.theme = "Nord";})
      ];

      home.packages = with pkgs.bat-extras; [
        batman
      ];

      programs.zsh.initContent = ''
        eval "$(batman --export-env)"
      '';

      # File manager
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        package = pkgs.yazi.override {
          # support for rar files
          _7zz = pkgs._7zz-rar;
        };
      };
    };
  };
}
