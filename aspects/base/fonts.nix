{
  my.aspects.base = let
    fontListFrom = pkgs:
      with pkgs; [
        # My favorite font, highly recommend it
        # https://typeof.net/Iosevka/
        nerd-fonts.iosevka-term
        nerd-fonts.iosevka
        (iosevka-bin.override {variant = "SS10";})
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
