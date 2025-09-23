{
  pkgs,
  config,
  username,
  ...
}: {
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
