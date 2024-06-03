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
        opacity = 0.85;
        blur = true;

        dynamic_padding = false;
        padding = {
          x = 10;
          y = 8;
        };
      };
    };
  };

  # tmux is must have for alacritty (because it has no tabs and panes
  # by default)
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    clock24 = true;
    historyLimit = 5000;

    keyMode = "vi";
    mouse = true;

    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      nord
      {
        plugin = better-mouse-mode;
        extraConfig = ''
          set -g @emulate-scroll-for-no-mouse-alternate-buffer "on"
        '';
      }
    ];

    prefix = "C-a";

    extraConfig = ''
      # switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
    '';
  };
}
