{
  pkgs,
  lib,
  private,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      import = ["${./terminal/alacritty-nord.toml}"];

      live_config_reload = true;

      font = {
        normal = {
          family = "IosevkaTerm Nerd Font";
          style = "Regular";
        };
        size = 16;
      };

      window = {
        decorations = "Buttonless";

        opacity = 0.85;
        blur = true;

        padding = {
          x = 18;
          y = 16;
        };
      };
    };
  };
}
