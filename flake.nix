{
  description = "NixOS/MacOS personal configs & dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # https://nix-community.github.io/home-manager/index.xhtml#ch-nix-flakes
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    globals = import ./globals.nix;
    private = import ./private.nix;

    inherit (nixpkgs.lib) recursiveUpdate;
    inherit (nixpkgs.lib.lists) foldl';
    mergeOutputs = foldl' recursiveUpdate {};

    mkDotfilesLink = hmConfig: path:
      hmConfig.lib.file.mkOutOfStoreSymlink "${hmConfig.home.homeDirectory}/nix/dotfiles/${path}";

    commonContext = {
      inherit inputs globals private mkDotfilesLink;
    };

    nixosSystem = host: params: let
      inherit (params) nixosModules hmModules;
      inherit (private.hosts.${host}) username hostname;
      context =
        commonContext
        // {
          inherit username hostname;
        };
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = context;

        modules =
          nixosModules
          ++ [
            ./hosts/${host}/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = context;

              home-manager.users.${username} = nixpkgs.lib.mkMerge [
                (import ./hosts/${host}/home.nix)
                {
                  imports = hmModules;
                }
              ];
            }
          ];
      };
    };

    macosSystem = host: params: let
      inherit (params) darwinModules hmModules;
      inherit (private.hosts.${host}) username hostname;
      context =
        commonContext
        // {
          inherit username hostname;
        };
    in {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = context;

        modules =
          [
            ./hosts/${host}/configuration.nix
          ]
          ++ darwinModules;
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          localSystem = "aarch64-darwin";
          config.allowUnfree = true;
        };
        extraSpecialArgs = context;

        modules = [./hosts/${host}/home.nix] ++ hmModules;
      };
    };
  in
    mergeOutputs [
      {
        formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
        formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
      }
      (nixosSystem "framework-13-amd-ai-300" {
        nixosModules = [
          ./nixos/base.nix
          ./nixos/hyprland.nix
          ./nixos/zen.nix
        ];
        hmModules = [
          ./hm/apps.nix
          ./hm/zsh.nix
          ./hm/git.nix
          ./hm/devtools.nix
          ./hm/gpg.nix
          ./hm/neovim.nix
          ./hm/terminal.nix
          ./hm/webos.nix
        ];
      })
      (nixosSystem "nixos-desktop" {
        nixosModules = [
          ./nixos/base.nix
          ./nixos/hyprland.nix
          ./nixos/zen.nix
          ./nixos/caddy.nix
          ./nixos/wakeonlan.nix
        ];
        hmModules = [
          ./hm/zsh.nix
          ./hm/git.nix
          ./hm/devtools.nix
          ./hm/gpg.nix
          ./hm/neovim.nix
          ./hm/terminal.nix
          ./hm/webos.nix
        ];
      })
      (macosSystem "macos-work" {
        darwinModules = [
          ./darwin/homebrew.nix
          ./darwin/caddy.nix
        ];
        hmModules = [
          ./hm/devtools.nix
          ./hm/git.nix
          ./hm/gpg.nix
          ./hm/neovim.nix
          ./hm/terminal.nix
          ./hm/webos.nix
          ./hm/zsh.nix
        ];
      })
    ];
}
