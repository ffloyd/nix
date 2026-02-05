# Objective: Hardware-specific configuration for desktop (Bluetooth and NVIDIA)
{...}: {
  hosts.nixos-desktop.nixosModules = [
    {
      # Enable bluetooth
      hardware.bluetooth.enable = true;

      # NVIDIA
      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia.open = false;
      # TODO: fix it before next application on the desktop
      # nixpkgs.config.cudaSupport = true;
    }
  ];
}
