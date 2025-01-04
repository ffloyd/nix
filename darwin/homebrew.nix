{
  pkgs,
  inputs,
  ...
}: {
  homebrew = {
    enable = true;

    taps = [
      "homebrew/bundle"
    ];

    brews = [
    ];

    casks = [
      # Essential
      "arc"
      "readdle-spark"
      "notion-calendar"
      "raycast"

      # Proton family
      "proton-mail"
      "proton-pass"

      # Work-related
      "loom"
      "notion"
      "linear-linear"

      # Social
      "telegram"
      "whatsapp"
      "discord"

      # Dev Tools
      "dash"
      "postman"
      "proxyman"

      # Tools
      "send-to-kindle"
      "domzilla-caffeine"
      "launchcontrol"

      # Entertaiment
      "spotify"
      "steam"
      "vlc"
      "kegworks" # wrapper for Windows games (for HOMM3 for example)
      "streetpea/streetpea/chiaki-ng" # stream games from my PS4
    ];
  };
}
