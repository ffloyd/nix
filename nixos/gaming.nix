{
  pkgs,
  config,
  username,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      gamescope = prev.gamescope.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            # https://github.com/ValveSoftware/gamescope/pull/1908
            (prev.fetchpatch {
              url = "https://github.com/ValveSoftware/gamescope/commit/fa900b0694ffc8b835b91ef47a96ed90ac94823b.diff";
              hash = "sha256-eIHhgonP6YtSqvZx2B98PT1Ej4/o0pdU+4ubdiBgBM4=";
            })
          ];
      });
    })
  ];

  programs.gamescope = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };

    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
    # localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;

  home-manager.users.${username} = {
    programs.lutris = {
      enable = true;
      steamPackage = config.programs.steam.package;
    };

    programs.mangohud.enable = true;
  };
}
