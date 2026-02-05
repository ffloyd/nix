# Bootloader configuration and Windows dualboot support
{
  my.hosts.nixos-desktop = {
    adjustments = [
      "Bootloader and Windows dualboot"
    ];

    nixos = {
      boot.loader.efi.canTouchEfiVariables = true;

      boot.loader.systemd-boot = {
        enable = true;
        edk2-uefi-shell.enable = true;
        windows."11" = {
          title = "Windows 11";
          efiDeviceHandle = "HD0b";
        };
      };
    };
  };
}
