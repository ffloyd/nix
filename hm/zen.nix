{
  config,
  pkgs,
  private,
  ...
}: {
  programs.zen-browser = {
    enable = true;
  };
}
