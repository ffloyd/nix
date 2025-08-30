# Objective: to run Spotify, but not the official client!
{
  username,
  ...
}: {
  nixpkgs.overlays = [
    # https://github.com/aome510/spotify-player/issues/802#issuecomment-3191659178
    (import ./spotify/overlay.nix)
  ];

  home-manager.users.${username} = {
    programs.spotify-player = {
      enable = true;
      settings = {
        client_id_command = "pass spotify/app_client_id";
      };
    };

    stylix.targets.spotify-player.enable = true;
  };
}
