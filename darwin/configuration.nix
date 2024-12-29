{
  pkgs,
  inputs,
  globals,
  private,
  ...
}: {
  imports = [
    ./homebrew.nix
    ./caddy.nix
    ./livebook.nix
  ];

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Globally installed packages
  environment.systemPackages = with pkgs; [];

  # Enable usage of Darwin-rebuild without passing path to this flake
  environment.darwinConfig = "$HOME/nix/flake.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Set trusted users for nix-daemon
  nix.settings.trusted-users = ["root" private.darwinUsername];

  # enable local linux builder
  # nix.linux-builder = {
  #   enable = true;
  #   config = {
  #     nix.extraOptions = ''
  #       sandbox = false
  #     '';
  #   };
  #   # package = pkgs.darwin.linux-builder-x86_64;
  #   # systems = ["x86_64-linux"];
  # };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = globals.nixExperimentalFeatures;

  # Allow ZSH from Nix as a default shell
  environment.shells = [pkgs.zsh];

  users.users.${private.darwinUsername} = {
    # we need it to enable home-manager
    home = "/Users/${private.darwinUsername}";
    shell = pkgs.zsh;
  };

  programs.zsh = {
    # Create /etc/zshrc that loads the nix-darwin environment.
    enable = true;
    # Should be disabled to allow additional fpath modifications in user's config
    enableGlobalCompInit = false;
  };

  fonts.packages = globals.getFonts pkgs;

  # enable Rosetta 2
  system.activationScripts.extraActivation.text = ''
    softwareupdate --install-rosetta --agree-to-license
  '';

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
