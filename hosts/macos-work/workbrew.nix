# Properly integrate workbrew with Zsh on macOS
{
  my.hosts.macos-work = {
    adjustments = [
      "Workbrew integration"
    ];

    darwin = {
      homebrew = {
        enable = true;

        # Workbrew is enforced by employer
        brewPrefix = "/opt/workbrew/bin";

        onActivation.cleanup = "uninstall";

        taps = [
          "jwbargsten/misc"
        ];

        brews = [
          "jwbargsten/misc/defbro"
        ];

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
          "livebook"

          # Dev Tools
          "dash"
          "postman"
          "proxyman"
          "tableplus"

          # Tools
          "domzilla-caffeine"
          "launchcontrol"
          # "winbox"

          # Entertaiment
          "spotify"
          "vlc"
        ];
      };
    };

    home = {lib, ...}: let
      inherit (lib) mkOrder mkMerge;
    in {
      programs.zsh = {
        # we need -u to disable security check
        # that complains about homebrew's `workbrew`
        # user being owner of completion-related brew files.
        completionInit = "autoload -U compinit && compinit -u";

        initContent = let
          zshConfigBeforeCompInit = mkOrder 550 ''
            FPATH="$(/opt/workbrew/bin/brew --prefix)/share/zsh/site-functions:''${FPATH}"
          '';

          zshConfig = mkOrder 1000 "eval \"$(/opt/workbrew/bin/brew shellenv)\"";
        in
          mkMerge [zshConfigBeforeCompInit zshConfig];
      };
    };
  };
}
