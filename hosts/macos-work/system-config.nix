# Objective: Basic system configuration and nix settings
{...}: let
  systemConfigModule = {
    pkgs,
    inputs,
    username,
    ...
  }: {
    # Globally installed packages
    environment.systemPackages = [];

    # Enable usage of Darwin-rebuild without passing path to this flake
    environment.darwinConfig = "$HOME/nix/flake.nix";

    # Set trusted users for nix-daemon
    nix.settings.trusted-users = ["root" username];

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

    # Set Git commit hash for darwin-version.
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
  };
in {
  hosts.macos-work.darwinModules = [systemConfigModule];
}
