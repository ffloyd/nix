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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    nix-homebrew,
    foundryvtt,
    zen-browser,
    walker,
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
        home-manager.nixosModules.home-manager
        foundryvtt.nixosModules.foundryvtt

        ./nixos/configuration.nix

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit globals private;};

          home-manager.sharedModules = [
            zen-browser.homeModules.beta
            walker.homeManagerModules.default
          ];

          nix.settings = {
            substituters = [
              "https://walker.cachix.org"
              "https://walker-git.cachix.org"
            ];
            trusted-public-keys = [
              "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
              "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
            ];
          };

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
