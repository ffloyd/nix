{
  my.aspects.base = let
    fontListFrom = pkgs:
      with pkgs; [
        # My favorite font, highly recommend it
        # https://typeof.net/Iosevka/
        nerd-fonts.iosevka-term
        nerd-fonts.iosevka
        (iosevka-bin.override {variant = "SS10";})
        (iosevka-bin.override {variant = "Etoile";})
        (iosevka-bin.override {variant = "Aile";})
      ];
  in {
    features = [
      ["common" "Global font installation"]
    ];

    nixos = {pkgs, ...}: {
      fonts = {
        enableDefaultPackages = true;
        packages = fontListFrom pkgs;
      };
    };

    darwin = {pkgs, ...}: {
      fonts.packages = fontListFrom pkgs;
    };
  };
}
