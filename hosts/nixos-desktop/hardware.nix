# Objective: Hardware-specific configuration for desktop (Bluetooth and NVIDIA)
{
  my.hosts.nixos-desktop = {
    adjustments = [
      "Desktop hardware tweaks"
    ];

    nixos = {
      # Enable bluetooth
      hardware.bluetooth.enable = true;

      # NVIDIA
      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia.open = false;
      # TODO: fix it before next application on the desktop
      # nixpkgs.config.cudaSupport = true;
    };
  };
}
