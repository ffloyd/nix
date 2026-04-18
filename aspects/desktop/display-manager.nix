{
  my.aspects.desktop = {
    features = [
      ["nixos" "greetd + regreet display manager setup"]
    ];

    nixos = {
      pkgs,
      lib,
      ...
    }: {
      programs.regreet = {
        enable = true;

        font.name = "Iosevka Etoile";
        font.size = 16;
        font.package = pkgs.iosevka-bin.override {variant = "Etoile";};

        settings = {
          background.path = "/etc/greetd/wallpaper";
          background.fit = "Cover";
          GTK.application_prefer_dark_theme = true;
          appearance.greeting_msg = "Welcome home!";
        };
      };

      # Run regreet inside Niri instead of cage for proper HiDPI support.
      # Minimal niri config at /etc/greetd/niri.kdl spawns regreet and exits.
      services.greetd.enable = true;
      services.greetd.settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.niri} --config /etc/greetd/niri.kdl";

      environment.etc."greetd/niri.kdl".text = ''
        // Greeter session: spawns regreet, then quits Niri after it exits
        spawn-sh-at-startup "${lib.getExe pkgs.regreet}; niri msg action quit --skip-confirmation"

        hotkey-overlay {
            skip-at-startup
        }

        // known for speeding up loading GTK apps
        environment {
          GTK_USE_PORTAL "0"
          GDK_DEBUG "no-portals"
        }

        prefer-no-csd
      '';
    };
  };
}
