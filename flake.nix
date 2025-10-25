{
  description = "NixOS/MacOS personal configs & dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Ahead-of-time nixpkgs: can be updated independently for accessing newer packages
    # without full system upgrade when main nixpkgs has build failures
    nixpkgs-aot.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    nix-ai-tools = {
      url = "github:numtide/nix-ai-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-inspect.url = "github:bluskript/nix-inspect";
    nixos-cli.url = "github:nix-community/nixos-cli";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ccusage-rs = {
      # using my fork with flakes support
      url = "github:ffloyd/ccusage-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    caelestia-shell = {
      # master is pretty unstable, so using tagged version
      url = "github:caelestia-dots/shell/v1.3.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    # Values that are used in multiple modules
    globals = import ./globals.nix;

    # Private data, like usernames, hostnames, etc.
    # (encrypted with git-crypt)
    private = import ./private.nix;

    # mkMerge cannot merge flake outputs,
    # and `//` operator cannot do deep merge,
    # so we need to use `recursiveUpdate` to merge flake outputs,
    # but it merges only 2 attrsets. `foldl'` makes it work with lists.
    inherit (nixpkgs.lib) recursiveUpdate;
    inherit (nixpkgs.lib.lists) foldl';
    mergeOutputs = foldl' recursiveUpdate {};

    # Waiting for nix to build for every change in dotfiles is annoying.
    # To opt-out of this, we can create direct symlinks to dotfiles bypassing the store.
    # The trick relies on home-manager's `mkOutOfStoreSymlink` function.
    mkDotfilesLink = hmConfig: path:
      hmConfig.lib.file.mkOutOfStoreSymlink "${hmConfig.home.homeDirectory}/nix/dotfiles/${path}";

    # Creates individual symlinks for each file in a directory.
    # Allows generated files (Nix store) and experimental files (dotfiles) to coexist.
    # Filters out .keep placeholder files used to make empty directories trackable in git.
    mkDotfilesDirectoryEntriesSymlinks = hmConfig: sourceDotfilesDir: targetPrefix: let
      entries = builtins.readDir ./dotfiles/${sourceDotfilesDir};
      mkSymlink = name: type:
        if type == "regular" && name != ".keep"
        then {"${targetPrefix}/${name}".source = mkDotfilesLink hmConfig "${sourceDotfilesDir}/${name}";}
        else {};
    in
      nixpkgs.lib.mkMerge (nixpkgs.lib.mapAttrsToList mkSymlink entries);

    # Converts attribute set to shell export statements for environment configuration files.
    # Values are properly escaped for shell using escapeShellArg.
    mkEnvExports = envVars:
      nixpkgs.lib.concatStringsSep "\n" (
        nixpkgs.lib.mapAttrsToList
        (name: value: "export ${name}=${nixpkgs.lib.escapeShellArg value}")
        envVars
      );

    # Shared configuration for all nixpkgs instances
    nixpkgsConfig = {
      allowUnfree = true;
    };

    # These attributes are passed to all NixOS, nix-darwin and home-manager modules.
    commonContext = {
      inherit inputs globals private mkDotfilesLink mkDotfilesDirectoryEntriesSymlinks mkEnvExports;
    };

    # A function that creates NixOS system configurations for a given host.
    # Also creates home-manager configuration for the user on this host.
    # For simplicity, home-manager configuration is merged inside NixOS configuration.
    #
    # Also it passes `username` and `hostname` from private data to the arguments of all modules.
    nixosSystem = host: params: let
      inherit (params) nixosModules hmModules;
      inherit (private.hosts.${host}) username hostname;

      system = "x86_64-linux";
      nixpkgsAttrs = {
        inherit system;
        config = nixpkgsConfig;
      };

      # Main nixpkgs instance
      pkgs = import nixpkgs nixpkgsAttrs;

      # Ahead-of-time nixpkgs for accessing newer packages without full system upgrade
      pkgs-aot = import inputs.nixpkgs-aot nixpkgsAttrs;

      context =
        commonContext
        // {
          inherit username hostname pkgs-aot;
          targetOS = "nixos";
        };
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = context;

        modules =
          nixosModules
          ++ [
            ./hosts/${host}/nixos.nix
            {
              nixpkgs.pkgs = pkgs;
              nix.settings.experimental-features = globals.nixExperimentalFeatures;
            }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = context;

              home-manager.users.${username} = nixpkgs.lib.mkMerge [
                {
                  imports = hmModules;
                }
              ];
            }
          ];
      };
    };

    # Creates macOS system configurations for a given host
    # alongside with home-manager configuration.
    #
    # In macOS, nix-darwin modules are rarely updated, but their application takes noticeable time,
    # so we have separate setup for nix-darwin and home-manager.
    macosSystem = host: params: let
      inherit (params) darwinModules hmModules;
      inherit (private.hosts.${host}) username hostname;

      system = "aarch64-darwin";
      nixpkgsAttrs = {
        inherit system;
        config = nixpkgsConfig;
      };

      # Main nixpkgs instance
      pkgs = import nixpkgs nixpkgsAttrs;

      # Ahead-of-time nixpkgs for accessing newer packages without full system upgrade
      pkgs-aot = import inputs.nixpkgs-aot nixpkgsAttrs;

      context =
        commonContext
        // {
          inherit username hostname pkgs-aot;
          targetOS = "macos";
        };
    in {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = context;

        modules =
          [
            ./hosts/${host}/nix-darwin.nix
            {
              nixpkgs.pkgs = pkgs;
              nix.settings.experimental-features = globals.nixExperimentalFeatures;
            }
          ]
          ++ darwinModules;
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = context;

        modules = [./hosts/${host}/home-manager.nix] ++ hmModules;
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
          ./nixos/desktop.nix
          ./nixos/browser.nix
          ./nixos/gaming.nix
          # ./nixos/remote-fs.nix
        ];
        hmModules = [
          ./hm/terminal.nix
          ./hm/shell.nix
          ./hm/gpg.nix
          ./hm/development-environment.nix
        ];
      })
      (nixosSystem "nixos-desktop" {
        nixosModules = [
          ./nixos/base.nix
          ./nixos/desktop.nix
          ./nixos/browser.nix
          ./nixos/local-reverse-proxy.nix
          ./nixos/wakeonlan.nix
        ];
        hmModules = [
          ./hm/terminal.nix
          ./hm/shell.nix
          ./hm/gpg.nix
          ./hm/development-environment.nix
        ];
      })
      (macosSystem "macos-work" {
        darwinModules = [
          ./darwin/workbrew.nix
          ./darwin/local-reverse-proxy.nix
        ];
        hmModules = [
          ./hm/terminal.nix
          ./hm/shell.nix
          ./hm/gpg.nix
          ./hm/development-environment.nix
        ];
      })
    ];
}
