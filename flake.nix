{
  description = "NixOS/MacOS system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # https://nix-community.github.io/home-manager/index.xhtml#ch-nix-flakes
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    globals = import ./globals.nix;
    private = import ./private.nix;
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;

    nixosConfigurations.${private.nixOsHost} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {inherit inputs globals private;};

      modules = [
        ./nixos/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit globals private;};

          home-manager.users.${private.nixOsUsername} = import ./nixos/home.nix;
        }
      ];
    };

    darwinConfigurations.${private.darwinHost} = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs globals private;};

      modules = [
        ./darwin/configuration.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit globals private;};

          home-manager.users.${private.darwinUsername} = import ./darwin/home.nix;
        }
      ];
    };
  };
}
