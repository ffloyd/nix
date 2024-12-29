{
  pkgs,
  private,
  ...
}: let
  workDir = "/Users/${private.darwinUsername}/Livebooks";
  context = with pkgs; [cmake git];
  contextPath = pkgs.lib.strings.concatStringsSep ":" (map (p: "${p}/bin") context);
in {
  launchd.user.agents.livebook = {
    command = "${pkgs.livebook}/bin/livebook start";

    environment = {
      LIVEBOOK_IP = "127.0.0.1";
      LIVEBOOK_PORT = "8080";

      LIVEBOOK_TOKEN_ENABLED = "false";
      ELIXIR_ERL_OPTIONS = "+sssdio 128";

      HOME = workDir;
      # It's not fully reproducible, but creating Apple-compatible
      # reproducible environment outside of Nix shell was too hard.
      #
      # Also I need XCode installed in order to build emlx NIFs:
      # mlx depends on metal libs, which are not available in the
      # Command Line Tools.
      PATH = "${contextPath}:/usr/bin:/usr/sbin:/bin:/sbin";
    };

    serviceConfig = {
      KeepAlive = true;
      WorkingDirectory = workDir;
      StandardErrorPath = "${workDir}/stderr";
      StandardOutPath = "${workDir}/stdout";
    };
  };
}
