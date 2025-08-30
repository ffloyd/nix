# Machine-specific NixOS configuration for desktop machine
#
# Objective: Centralize machine-specific configurations while keeping the rest of the config clean
# of device-specific workarounds. Machine-specific tweaks may exist in other modules when extraction
# here would be inconvenien.
{
  config,
  pkgs,
  globals,
  private,
  username,
  hostname,
  ...
}: {
  imports = [
    #
    # State versions
    #
    {
      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "24.11"; # Did you read the comment?

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home-manager.users.${username}.home.stateVersion = "24.11"; # Please read the comment before changing.
    }

    #
    # Hardware setup
    #
    ./hardware-configuration.nix
    {
      # Enable bluetooth
      hardware.bluetooth.enable = true;

      # NVIDIA
      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia.open = false;
      nixpkgs.config.cudaSupport = true;
    }

    #
    # Bootloader and dualboot with Windows
    #
    {
      boot.loader.efi.canTouchEfiVariables = true;

      boot.loader.systemd-boot = {
        enable = true;
        edk2-uefi-shell.enable = true;
        windows."11" = {
          title = "Windows 11";
          efiDeviceHandle = "HD0b";
        };
      };

      home-manager.users.${username}.programs.zsh.shellAliases = {
        os-reboot-to-windows = "sudo systemctl reboot --boot-loader-entry=windows_11.conf";
      };
    }
  ];
}
