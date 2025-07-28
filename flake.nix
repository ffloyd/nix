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

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    nix-homebrew,
    foundryvtt,
    ...
  } @ inputs: let
    # These attribute sets are passed to all modules here, both NixOS and
    # Darwin.
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
        foundryvtt.nixosModules.foundryvtt

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
        nix-homebrew.darwinModules.nix-homebrew
        ./darwin/configuration.nix
      ];
    };

    homeConfigurations.${private.darwinUsername} = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        localSystem = "aarch64-darwin";
        config.allowUnfree = true;
      };
      extraSpecialArgs = {inherit globals private;};

      modules = [./darwin/home.nix];
    };
  };
}
