{config, ...}: let
  inherit (config.my.consts) fullName;
in {
  my.aspects.base = {
    features = [
      ["nixos" "User account"]
    ];

    nixos = {username, ...}: {
      users.users.${username} = {
        isNormalUser = true;
        description = fullName;
        extraGroups = ["networkmanager" "wheel"];
        packages = [];
      };
    };
  };
}
