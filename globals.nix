{
  nixExperimentalFeatures = ["nix-command" "flakes" "repl-flake"];

  getFonts = pkgs:
    with pkgs; [
      # list of fonts here: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
      (nerdfonts.override {fonts = ["IosevkaTerm" "Iosevka"];})
      (iosevka-bin.override {variant = "SS10";})
    ];
}
