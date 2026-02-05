# Global configuration values shared across all hosts
{lib, ...}: {
  config.globals = {
    nixExperimentalFeatures = ["nix-command" "flakes"];

    getFonts = pkgs:
      with pkgs; [
        nerd-fonts.iosevka-term
        nerd-fonts.iosevka
        (iosevka-bin.override {variant = "SS10";})

        # required by HyprPanel
        nerd-fonts.jetbrains-mono
      ];
  };

  options.globals = {
    nixExperimentalFeatures = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of experimental Nix features to enable across all configurations";
    };

    getFonts = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = ''
        Function that takes pkgs and returns a list of font packages.
        These fonts are installed globally across all systems.
      '';
    };
  };
}
