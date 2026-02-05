{inputs, ...}: {
  my.aspects.base = {
    features = [
      ["nixos" "Stylix cross-app theming engine"]
    ];

    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.stylix.nixosModules.stylix];

      stylix = {
        enable = true;
        autoEnable = false;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        image = ./theming/bg.jpg;

        fonts = {
          monospace = {
            name = "IosevkaTerm Nerd Font Mono";
            package = pkgs.nerd-fonts.iosevka-term;
          };
          serif = {
            name = "Iosevka Nerd Font Propo";
            package = pkgs.nerd-fonts.iosevka;
          };
          sansSerif = config.stylix.fonts.serif;
          emoji = config.stylix.fonts.serif;
        };
      };
    };
  };
}
