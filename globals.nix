{
  nixExperimentalFeatures = ["nix-command" "flakes"];

  getFonts = pkgs:
    with pkgs; [
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka
      (iosevka-bin.override {variant = "SS10";})
    ];
}
