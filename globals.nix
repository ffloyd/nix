{
  nixExperimentalFeatures = ["nix-command" "flakes"];

  getFonts = pkgs:
    with pkgs; [
      # list of fonts here: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka
      (iosevka-bin.override {variant = "SS10";})
    ];
}
