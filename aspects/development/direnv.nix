{
  my.aspects.development = {
    features = [
      ["common" "Direnv with nix-direnv integration"]
    ];

    home = {
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
