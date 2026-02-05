{inputs, ...}: {
  my.aspects.base = {
    features = [
      ["nixos" "Flatpak support"]
    ];

    nixos = {
      services.flatpak.enable = true;
    };

    homeNixos = {pkgs, ...}: {
      imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];

      home.packages = [pkgs.flatpak];
    };
  };
}
