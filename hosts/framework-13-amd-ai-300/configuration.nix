# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}: {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  imports = [
    ./hardware-configuration.nix

    # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/amd-ai-300-series
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  #
  # Apply audio enchancement made by community
  #
  # Original audio sound on Framework 13 is awful =(
  #
  hardware.framework.laptop13.audioEnhancement.enable = true;

  #
  # Enable all firmware (including unfree, etc.)
  #
  hardware.enableAllFirmware = true;

  #
  # Adjust internal keyboard behavior
  #
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["0001:0001:70533846"];
      settings = {
        main = {
          # left alt <-> left cmd
          # this is also done physically on the keyboard
          leftalt = "leftmeta";
          leftmeta = "leftalt";
          # capslock -> (held) ctrl, (tap) ESC
          capslock = "overloadt2(control, esc, 150)";
        };
      };
    };
  };

  #
  # Decrypt LUKS partitions on boot
  #
  boot.initrd.luks.devices."luks-584448a8-c11d-4f10-828a-31a1267eef0f".device = "/dev/disk/by-uuid/584448a8-c11d-4f10-828a-31a1267eef0f";

  #
  # Use latest kernel
  #
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #
  # Bootloader configuration
  #

  # systemd-boot works with minimal config and very reliable.
  # But it looks bad on hdpi. Pressing `r` once sytemd-boot is loaded
  # will switch to consolemod with lower resolution, so it's not a problem
  # considering that we hide boot menu by default.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    # show menu it only if user spams some button
    # this trick will preserve Framework logo on boot.
    timeout = 0;
  };

  # Silent boot: so Framework logo will be replaced with Plymouth seamless
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    # this two makes initrd really quiet
    "quiet"
    "udev.log_level=3"
    # required by Plymouth
    "splash"
    # allow Plymouth to render before amdgpu driver is loaded
    # by reusing EFI's simpledrm
    "plymouth.use-simpledrm"
    # this (maybe) reduces flickering on boot
    "amdgpu.seamless=1"
  ];

  # Plymouth: make loading screen look nice
  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [
      pkgs.nixos-bgrt-plymouth
    ];
  };

  # Unresolved Plymouth issues at the moment of writing:
  #
  # - Plymouth sometimes fails and boot happens in text mode
  # - When external monitor is connected, Plymouth is rendered on it with bad placement

  #
  # Firmware updates
  #
  services.fwupd.enable = true;

  #
  # This is required for proper power management
  #
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  #
  # Bluetooth
  #
  hardware.bluetooth.enable = true;
}
