{
  description = "NixOS/MacOS personal configs & dotfiles";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

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
      url = "github:ffloyd/nix-foundryvtt";
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

    opencode.url = "github:sst/opencode/v1.1.48";

    nix-inspect.url = "github:bluskript/nix-inspect";
    nixos-cli.url = "github:nix-community/nixos-cli";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;

      systems = ["x86_64-linux" "aarch64-darwin"];

      imports = [
        ./globals.nix
        ./private.nix
        ./hosts-option.nix
        (import-tree ./hosts)
        (import-tree ./nixos)
        (import-tree ./darwin)

        inputs.home-manager.flakeModules.home-manager
        (import-tree ./hm)
      ];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}
