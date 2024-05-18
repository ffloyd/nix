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
      "brave-browser"
      "readdle-spark"
      "iterm2"

      "loom"
      "notion"
      "notion-calendar"
      "linear-linear"

      "telegram"
      "whatsapp"
      "discord"

      "dash"
      "postman"

      "send-to-kindle"

      "spotify"
      "steam"
      "vlc"

      "proxyman"
      "livebook"
    ];
  };
}
