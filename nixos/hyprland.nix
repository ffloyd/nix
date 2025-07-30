{
  pkgs,
  config,
  ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
  };

  programs.regreet = {
    enable = true;
  };
}
