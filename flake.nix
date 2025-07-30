{
  description = "NixOS/MacOS personal configs & dotfiles";

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
    foundryvtt,
    zen-browser,
    walker,
    ...
  } @ inputs: let
    globals = import ./globals.nix;
    private = import ./private.nix;
    nixosSystem = host: nixosModules: hmModules: let
      inherit (private.hosts.${host}) username hostname;
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs globals private username hostname;
        };

        modules =
          nixosModules
          ++ [
            ./hosts/${host}/configuration.nix

            home-manager.nixosModules.home-manager
            foundryvtt.nixosModules.foundryvtt

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit globals private username hostname;
              };

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

              home-manager.users.${username} =
                import ./hosts/${host}/home.nix
                // {
                  imports = hmModules;
                };
            }
          ];
      };
    };
    macosSystem = host: darwinModules: hmModules: let
      inherit (private.hosts.${host}) username hostname;
    in {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs globals private username hostname;
        };

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
        extraSpecialArgs = {
          inherit globals private username hostname;
        };

        modules = [./hosts/${host}/home.nix] ++ hmModules;
      };
    };
  in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    }
    // (nixosSystem "nixos-desktop" [
        ./nixos/hyprland.nix
        ./nixos/caddy.nix
        # ./nixos/foundryvtt.nix
        # ./nixos/livebook.nix
        # ./nixos/ollama.nix
        # ./nixos/open-webui.nix
        ./nixos/wakeonlan.nix
      ] [
        ./hm/zsh.nix
        ./hm/git.nix
        ./hm/devtools.nix
        ./hm/gpg.nix
        ./hm/neovim.nix
        ./hm/terminal.nix
        ./hm/webos.nix
        ./hm/hyprland.nix
        ./hm/zen.nix
      ])
    // (macosSystem "macos-work" [
        ./darwin/homebrew.nix
        ./darwin/caddy.nix
      ] [
        ./hm/devtools.nix
        ./hm/git.nix
        ./hm/gpg.nix
        ./hm/neovim.nix
        ./hm/terminal.nix
        ./hm/webos.nix
        ./hm/zsh.nix
      ]);
}
