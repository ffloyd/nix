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
    foundryvtt,
    zen-browser,
    walker,
    ...
  } @ inputs: let
    globals = import ./globals.nix;
    private = import ./private.nix;
    nixosSystem = host: params: let
      inherit (params) nixosModules hmModules;
      inherit (private.hosts.${host}) username hostname;
      context = {
        inherit inputs globals private username hostname;
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
            foundryvtt.nixosModules.foundryvtt

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = context;

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
      context = {
        inherit inputs globals private username hostname;
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
    inherit (nixpkgs.lib) recursiveUpdate;
    inherit (nixpkgs.lib.lists) foldl';
  in
    foldl' recursiveUpdate {} [
      {
        formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
        formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
      }
      (nixosSystem "framework-13-amd-ai-300" {
        nixosModules = [
          ./nixos/base.nix
          ./nixos/hyprland.nix
        ];
        hmModules = [
          ./hm/hyprland.nix
          ./hm/apps.nix
          ./hm/zsh.nix
          ./hm/git.nix
          ./hm/devtools.nix
          ./hm/gpg.nix
          ./hm/neovim.nix
          ./hm/terminal.nix
          ./hm/webos.nix
          ./hm/zen.nix
        ];
      })
      (nixosSystem "nixos-desktop" {
        nixosModules = [
          ./nixos/base.nix
          ./nixos/hyprland.nix
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
          ./hm/hyprland.nix
          ./hm/zen.nix
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
