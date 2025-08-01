{
  nixExperimentalFeatures = ["nix-command" "flakes"];

  getFonts = pkgs:
    with pkgs; [
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      (iosevka-bin.override {variant = "SS10";})
    ];
}
