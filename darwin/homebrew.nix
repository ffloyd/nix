_: {
  homebrew = {
    enable = true;

    # Enforced by employer
    brewPrefix = "/opt/workbrew/bin";

    onActivation.cleanup = "uninstall";

    taps = [
      "jwbargsten/misc"
    ];

    brews = [
      "jwbargsten/misc/defbro"
    ];

    # commented out casks are already installed on machine and cannot be adopted by homebrew
    casks = [
      # Essential
      "arc"
      "notion-calendar"
      "raycast"
      "anytype"

      # Proton family
      "proton-drive"

      # Work-related
      "loom"
      "notion"
      "linear-linear"

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

      # Entertaiment
      "spotify"
      "vlc"
    ];
  };
}
