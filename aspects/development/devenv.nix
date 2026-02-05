{
  my.aspects.development = {
    features = [
      ["common" "Devenv installation and cache setup"]
    ];

    home = {pkgs, ...}: {
      nix.extraOptions = ''
        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      '';

      home.packages = with pkgs; [
        devenv
      ];
    };
  };
}
