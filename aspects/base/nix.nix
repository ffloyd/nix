{inputs, ...}: {
  my.aspects.base = let
    enbaledNixExperimentalFeatures = ["nix-command" "flakes"];
  in {
    features = [
      ["nixos" "nixos-cli as a convinient wrapper for nixos-rebuild, etc."]
      ["nixos" "Nix inspection tools (nix-tree, nix-inspect)"]
      ["common" "Shell aliases for common operations"]
      ["macos" "Essential Home Manager adjustments"]
      ["macos" "Essential nix-darwin adjustments"]
    ];

    nixos = {
      pkgs,
      system,
      username,
      ...
    }: {
      imports = [inputs.nixos-cli.nixosModules.nixos-cli];

      services.nixos-cli = {
        enable = true;
        config = {
          config_location = "/home/${username}/nix";
          use_nvd = true;
          apply.use_nom = true;
        };
      };

      nix.settings = {
        experimental-features = enbaledNixExperimentalFeatures;
        substituters = ["https://watersucks.cachix.org"];
        trusted-public-keys = [
          "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
        ];
        # Allow user to use nix features that require elevated privileges
        trusted-users = ["root" username];
      };

      environment.systemPackages = [
        inputs.nix-inspect.packages.${system}.default
        pkgs.nix-tree

        # used by nixos-cli:
        pkgs.nix-output-monitor
        pkgs.nvd
      ];
    };

    homeNixos = {
      programs.zsh.shellAliases = {
        os-rebuild = "nixos apply --local-root";
        os-rebuild-boot = "nixos apply --no-activate --install-bootloader";
        os-gc = "nixos generation delete --min 5 --all";
        nixpkgs-search-exec = "nix-env -qaP";
      };
    };

    darwin = {username, ...}: {
      # Enable usage of Darwin-rebuild without passing path to this flake
      environment.darwinConfig = "$HOME/nix/flake.nix";

      # Set trusted users for nix-daemon
      nix.settings.trusted-users = ["root" username];
      nix.settings.experimental-features = enbaledNixExperimentalFeatures;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

      # we need it to enable home-manager
      users.users.${username}.home = "/Users/${username}";
    };

    homeDarwin = {
      pkgs,
      username,
      ...
    }: {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      # Otherwise home-manager fails with error on Darwin
      nix.package = pkgs.nix;

      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      home.username = username;
      home.homeDirectory = "/Users/${username}";

      programs.zsh.shellAliases = {
        os-rebuild = "sudo darwin-rebuild switch --flake /Users/${username}/nix";
        hm-rebuild = "home-manager switch --flake ~/nix";
      };
    };
  };
}
