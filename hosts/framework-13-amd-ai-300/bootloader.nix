# Objective: Bootloader, kernel, and disk encryption configuration
{
  my.hosts.framework-13-amd-ai-300 = {
    adjustments = [
      "Bootloader and disk encryption"
    ];

    nixos = {pkgs, ...}: {
      # Decrypt LUKS partitions on boot
      boot.initrd.luks.devices."luks-584448a8-c11d-4f10-828a-31a1267eef0f".device = "/dev/disk/by-uuid/584448a8-c11d-4f10-828a-31a1267eef0f";

      # Use latest kernel
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # `systemd-boot` works with minimal config and very reliable.
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
    };
  };
}
