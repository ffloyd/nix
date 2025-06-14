{
  pkgs,
  inputs,
  ...
}: {
  homebrew = {
    enable = true;

    onActivation.cleanup = "uninstall";

    taps = [
      "homebrew/bundle"
      "kegworks-app/kegworks"
      "streetpea/streetpea"
      "jwbargsten/misc"
    ];

    brews = [
      "defbro"
    ];

    casks = [
      # Essential
      "arc"
      "firefox@developer-edition"
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
      "xmind"
      "freeplane"

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
      "send-to-kindle"
      "domzilla-caffeine"
      "launchcontrol"
      "winbox"

      # Entertaiment
      "spotify"
      "steam"
      "vlc"
      "kegworks" # wrapper for Windows games (for HOMM3 for example)
      "streetpea/streetpea/chiaki-ng" # stream games from my PS4
      "moonlight" # stream games from my gaming rig
    ];
  };
}
