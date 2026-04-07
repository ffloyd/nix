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

    # darwin builds of the most recent versions often broken
    opencode-linux = {
      url = "github:sst/opencode/v1.3.17";
      # 1.2.1 had problems with its nixpkgs pin:
      # https://github.com/anomalyco/opencode/issues/13300
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode-darwin.url = "github:sst/opencode/v1.1.49";

    nix-inspect.url = "github:bluskript/nix-inspect";
    nixos-cli.url = "github:nix-community/nixos-cli";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/?ref=v4.7.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = false;

      systems = ["x86_64-linux" "aarch64-darwin"];

      imports = [
        (import-tree ./my)
        (import-tree ./aspects)
        (import-tree ./hosts)

        ./private.nix

        # Darwin systems use nix-darwin and home-manager separately,
        # so we need a properly typed flake output
        inputs.home-manager.flakeModules.home-manager
      ];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}
