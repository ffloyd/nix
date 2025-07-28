{
  pkgs,
  inputs,
  private,
  ...
}: {
  nix-homebrew = {
    enable = false;

    # User owning the Homebrew prefix
    user = private.darwinUsername;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;
  };

  homebrew = {
    enable = true;

    brewPrefix = "/opt/workbrew/bin";

    onActivation.cleanup = "uninstall";

    taps = [
      "kegworks-app/kegworks"
      "streetpea/streetpea"
      "jwbargsten/misc"
    ];

    brews = [
      "jwbargsten/misc/defbro"
    ];

    # commented out casks are already installed on machine and cannot be adopted by homebrew
    casks = [
      # Essential
      "arc"
      "zen"
      "readdle-spark"
      "notion-calendar"
      "raycast"
      "anytype"

      # Proton family
      "proton-mail"
      "proton-pass"

      # Work-related
      "loom"
      "notion"
      "linear-linear"
      # "xmind"
      # "freeplane"

      # Social
      "telegram"
      "whatsapp"
      "discord"

      # Dev Tools
      "dash"
      "postman"
      "proxyman"
      "tableplus"

      # Tools
      # "send-to-kindle"
      "domzilla-caffeine"
      "launchcontrol"
      # "winbox"

      # Web Site Development
      "screaming-frog-seo-spider"

      # Entertaiment
      "spotify"
      "steam"
      "vlc"
      "kegworks" # wrapper for Windows games (for HOMM3 for example)
      # "streetpea/streetpea/chiaki-ng" # stream games from my PS4
      "moonlight" # stream games from my gaming rig
    ];
  };
}
