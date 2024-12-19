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
      "livebook"

      # Tools
      "send-to-kindle"

      # Entertaiment
      "spotify"
      "steam"
      "vlc"
      "kegworks" # wrapper for Windows games (for HOMM3 for example)
      "streetpea/streetpea/chiaki-ng" # stream games from my PS4
    ];
  };
}
