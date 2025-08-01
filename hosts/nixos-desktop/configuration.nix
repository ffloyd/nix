# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  globals,
  private,
  username,
  hostname,
  ...
}: {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  imports = [./hardware-configuration.nix];

  #
  # Bootloader and dualboot with Windows
  #
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    edk2-uefi-shell.enable = true;
    windows."11" = {
      title = "Windows 11";
      efiDeviceHandle = "HD0b";
    };
  };

  #
  # Enable bluetooth
  #
  hardware.bluetooth.enable = true;

  # NVIDIA
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = false;
  nixpkgs.config.cudaSupport = true;
}
